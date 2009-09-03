# This file is generated by rake. Do not edit.

module JNI
  JNI::EnvFunctions.each_function do |name, arg_types, return_type, block|
  	callback name, arg_types, return_type
  end
  
  class EnvStruct < FFI::Struct
    layout :GetVersion, :GetVersion, 16,
           :ExceptionOccurred, :ExceptionOccurred, 60,
           :NewGlobalRef, :NewGlobalRef, 84,
           :DeleteGlobalRef, :DeleteGlobalRef, 88,
           :IsSameObject, :IsSameObject, 96,
           :GetObjectClass, :GetObjectClass, 124,
           :GetMethodID, :GetMethodID, 132,
           :CallByteMethod, :CallByteMethod, 160,
           :CallCharMethod, :CallCharMethod, 172,
           :CallShortMethod, :CallShortMethod, 184,
           :CallIntMethod, :CallIntMethod, 196,
           :CallLongMethod, :CallLongMethod, 208,
           :CallFloatMethod, :CallFloatMethod, 220,
           :CallDoubleMethod, :CallDoubleMethod, 232,
           :CallByteMethodV, :CallByteMethodV, 164,
           :CallCharMethodV, :CallCharMethodV, 176,
           :CallShortMethodV, :CallShortMethodV, 188,
           :CallIntMethodV, :CallIntMethodV, 200,
           :CallLongMethodV, :CallLongMethodV, 212,
           :CallFloatMethodV, :CallFloatMethodV, 224,
           :CallDoubleMethodV, :CallDoubleMethodV, 236,
           :GetFieldID, :GetFieldID, 376,
           :GetObjectField, :GetObjectField, 380,
           :GetBooleanField, :GetBooleanField, 384,
           :GetByteField, :GetByteField, 388,
           :GetCharField, :GetCharField, 392,
           :GetShortField, :GetShortField, 396,
           :GetIntField, :GetIntField, 400,
           :GetLongField, :GetLongField, 404,
           :GetFloatField, :GetFloatField, 408,
           :GetDoubleField, :GetDoubleField, 412,
           :SetBooleanField, :SetBooleanField, 420,
           :SetByteField, :SetByteField, 424,
           :SetCharField, :SetCharField, 428,
           :SetShortField, :SetShortField, 432,
           :SetIntField, :SetIntField, 436,
           :SetLongField, :SetLongField, 440,
           :SetFloatField, :SetFloatField, 444,
           :SetDoubleField, :SetDoubleField, 448,
           :GetStaticMethodID, :GetStaticMethodID, 452,
           :CallStaticByteMethod, :CallStaticByteMethod, 480,
           :CallStaticCharMethod, :CallStaticCharMethod, 492,
           :CallStaticShortMethod, :CallStaticShortMethod, 504,
           :CallStaticIntMethod, :CallStaticIntMethod, 516,
           :CallStaticLongMethod, :CallStaticLongMethod, 528,
           :CallStaticFloatMethod, :CallStaticFloatMethod, 540,
           :CallStaticDoubleMethod, :CallStaticDoubleMethod, 552,
           :CallStaticByteMethodV, :CallStaticByteMethodV, 484,
           :CallStaticCharMethodV, :CallStaticCharMethodV, 496,
           :CallStaticShortMethodV, :CallStaticShortMethodV, 508,
           :CallStaticIntMethodV, :CallStaticIntMethodV, 520,
           :CallStaticLongMethodV, :CallStaticLongMethodV, 532,
           :CallStaticFloatMethodV, :CallStaticFloatMethodV, 544,
           :CallStaticDoubleMethodV, :CallStaticDoubleMethodV, 556,
           :GetStringUTFChars, :GetStringUTFChars, 676,
           :ReleaseStringUTFChars, :ReleaseStringUTFChars, 680,
           :NewByteArray, :NewByteArray, 704,
           :NewCharArray, :NewCharArray, 708,
           :NewShortArray, :NewShortArray, 712,
           :NewIntArray, :NewIntArray, 716,
           :NewLongArray, :NewLongArray, 720,
           :NewFloatArray, :NewFloatArray, 724,
           :NewDoubleArray, :NewDoubleArray, 728,
           :GetBooleanArrayElements, :GetBooleanArrayElements, 732,
           :GetByteArrayElements, :GetByteArrayElements, 736,
           :GetCharArrayElements, :GetCharArrayElements, 740,
           :GetShortArrayElements, :GetShortArrayElements, 744,
           :GetIntArrayElements, :GetIntArrayElements, 748,
           :GetLongArrayElements, :GetLongArrayElements, 752,
           :GetFloatArrayElements, :GetFloatArrayElements, 756,
           :GetDoubleArrayElements, :GetDoubleArrayElements, 760,
           :ReleaseBooleanArrayElements, :ReleaseBooleanArrayElements, 764,
           :ReleaseByteArrayElements, :ReleaseByteArrayElements, 768,
           :ReleaseCharArrayElements, :ReleaseCharArrayElements, 772,
           :ReleaseShortArrayElements, :ReleaseShortArrayElements, 776,
           :ReleaseIntArrayElements, :ReleaseIntArrayElements, 780,
           :ReleaseLongArrayElements, :ReleaseLongArrayElements, 784,
           :ReleaseFloatArrayElements, :ReleaseFloatArrayElements, 788,
           :ReleaseDoubleArrayElements, :ReleaseDoubleArrayElements, 792,
           :GetByteArrayRegion, :GetByteArrayRegion, 800,
           :GetCharArrayRegion, :GetCharArrayRegion, 804,
           :GetShortArrayRegion, :GetShortArrayRegion, 808,
           :GetIntArrayRegion, :GetIntArrayRegion, 812,
           :GetLongArrayRegion, :GetLongArrayRegion, 816,
           :GetFloatArrayRegion, :GetFloatArrayRegion, 820,
           :GetDoubleArrayRegion, :GetDoubleArrayRegion, 824,
           :SetByteArrayRegion, :SetByteArrayRegion, 832,
           :SetCharArrayRegion, :SetCharArrayRegion, 836,
           :SetShortArrayRegion, :SetShortArrayRegion, 840,
           :SetIntArrayRegion, :SetIntArrayRegion, 844,
           :SetLongArrayRegion, :SetLongArrayRegion, 848,
           :SetFloatArrayRegion, :SetFloatArrayRegion, 852,
           :SetDoubleArrayRegion, :SetDoubleArrayRegion, 856,
           :GetJavaVM, :GetJavaVM, 876
  end
  
  JNI::JvmFunctions.each_function do |name, arg_types, return_type, block|
  	callback name, arg_types, return_type
  end
  
  class JvmStruct < FFI::Struct
    layout :AttachCurrentThread, :AttachCurrentThread, 16








  end
end
