#include <stdarg.h>

int va_arg_int32_direct(va_list list) {
  return va_arg(list, int);
}

long va_arg_int64_direct(va_list list) {
  return va_arg(list, long);
}

int va_arg_int32_pointer(va_list* list_ptr) {
  return va_arg(*list_ptr, int);;
}

long va_arg_int64_pointer(va_list* list_ptr) {
  return va_arg(*list_ptr, long);;
}
