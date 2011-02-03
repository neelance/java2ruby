module Java2Ruby
  class ConversionController
    attr_reader :prefix, :prefix_class_names, :constants, :no_constants, :constant_name_mapping, :field_name_mapping
    
    def initialize
      @current_converter_id = 0
      @pending_converters = {}
      @queued_converters = []
      @failed_converters = []
      @amount_to_convert = 0
      @converted_amount = 0
    end
    
    def add_files(files, src_dir, lib_dir, tmp_dir, conversion_rules)
      files.each do |file|
        src_file = "#{src_dir}/#{file}"  
        next if File.directory? src_file
        
        if File.extname(file) == ".java"
          lib_file_dir = "#{lib_dir}/#{File.dirname(file)}"
          tmp_file_dir = "#{tmp_dir}/#{File.dirname(file)}"
          mkdir_p lib_file_dir unless File.exist? lib_file_dir
          mkdir_p tmp_file_dir unless File.exist? tmp_file_dir
          
          size = File.size src_file
          @amount_to_convert += size
          converter = Java2Ruby::Converter.new src_file, lib_file_dir, tmp_file_dir, conversion_rules, @current_converter_id, size
          if converter.nothing_to_do?
            @converted_amount += size
          else
            @current_converter_id += 1
            @pending_converters[converter.converter_id] = converter
            @queued_converters << converter
          end
        else
          lib_file = "#{lib_dir}/#{file}"
          lib_file_dir = File.dirname lib_file
          mkdir_p lib_file_dir unless File.exist? lib_file_dir
          cp src_file, lib_file unless File.exist? lib_file
        end
      end
    end
    
    def run(process_count)
      if process_count.nil?
        ConversionController.client_convert_loop self, true
      else
        File.delete "drburi" if File.exist? "drburi"
        process_count.to_i.times do
          fork do
            DRb.start_service
            sleep 0.1 until File.exist? "drburi"
            controller = DRbObject.new nil, File.read("drburi")
            ConversionController.client_convert_loop controller, false
          end
        end
        DRb.start_service nil, self
        File.open("drburi", "w") do |file|
          file.write DRb.uri
        end
        sleep 1 until @pending_converters.empty?
        File.delete "drburi"
      end
      
      puts "Conversions complete" + (@failed_converters.empty? ? "" : ", but some of them failed:")
      @failed_converters.each do |converter|
        puts "#{converter.java_file}: #{converter.error}"
      end
    end
    
    def fetch_converter
      converter = @queued_converters.shift
      percent = format "%.2f", (@converted_amount.quo(@amount_to_convert) * 100)
      print "java2ruby #{File.basename converter.java_file} (#{percent}% - #{@pending_converters.size} left)\n" if converter
      converter
    end
    
    def converter_complete(converter_id)
      converter = @pending_converters.delete converter_id
      @converted_amount += converter.size
      nil
    end
    
    def converter_failed(converter_id, error)
      converter = @pending_converters.delete converter_id
      @converted_amount += converter.size
      converter.error = error
      @failed_converters << converter
      puts "Conversion failed: #{converter.java_file} (#{converter.error})"
      nil
    end
    
    def self.client_convert_loop(remote_controller, fail_on_error)
      loop do
        converter = remote_controller.fetch_converter
        break if converter.nil?
        begin
          converter.convert
          remote_controller.converter_complete converter.converter_id
        rescue Interrupt
          exit
        rescue Exception => e
          raise if fail_on_error
          remote_controller.converter_failed converter.converter_id, e.to_s
        end
      end
    end
  end
end