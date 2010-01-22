#include <stdarg.h>
#include "jni.h"

JNIEXPORT int (JNICALL va_arg_int32_direct) (va_list list) {
  return va_arg(list, int);
}

JNIEXPORT long (JNICALL va_arg_int64_direct) (va_list list) {
  return va_arg(list, long);
}

JNIEXPORT int (JNICALL va_arg_int32_pointer) (va_list* list_ptr) {
  return va_arg(*list_ptr, int);
}

JNIEXPORT long (JNICALL va_arg_int64_pointer) (va_list* list_ptr) {
  return va_arg(*list_ptr, long);
}


jobject (JNICALL CallStaticObjectMethod) (JNIEnv *env, jclass clazz, jmethodID methodID, ...) {
  va_list list;
  jobject value;
  va_start(list, methodID);
  value = (*env)->CallStaticObjectMethodV(env, clazz, methodID, list);
  va_end(list);
  return value;
}
JNIEXPORT long (JNICALL CallStaticObjectMethodAddress) () {
  return (long) CallStaticObjectMethod;
}

jboolean (JNICALL CallStaticBooleanMethod) (JNIEnv *env, jclass clazz, jmethodID methodID, ...) {
  va_list list;
  jboolean value;
  va_start(list, methodID);
  value = (*env)->CallStaticBooleanMethodV(env, clazz, methodID, list);
  va_end(list);
  return value;
}
JNIEXPORT long (JNICALL CallStaticBooleanMethodAddress) () {
  return (long) CallStaticBooleanMethod;
}

jbyte (JNICALL CallStaticByteMethod) (JNIEnv *env, jclass clazz, jmethodID methodID, ...) {
  va_list list;
  jbyte value;
  va_start(list, methodID);
  value = (*env)->CallStaticByteMethodV(env, clazz, methodID, list);
  va_end(list);
  return value;
}
JNIEXPORT long (JNICALL CallStaticByteMethodAddress) () {
  return (long) CallStaticByteMethod;
}

jchar (JNICALL CallStaticCharMethod) (JNIEnv *env, jclass clazz, jmethodID methodID, ...) {
  va_list list;
  jchar value;
  va_start(list, methodID);
  value = (*env)->CallStaticCharMethodV(env, clazz, methodID, list);
  va_end(list);
  return value;
}
JNIEXPORT long (JNICALL CallStaticCharMethodAddress) () {
  return (long) CallStaticCharMethod;
}

jshort (JNICALL CallStaticShortMethod) (JNIEnv *env, jclass clazz, jmethodID methodID, ...) {
  va_list list;
  jshort value;
  va_start(list, methodID);
  value = (*env)->CallStaticShortMethodV(env, clazz, methodID, list);
  va_end(list);
  return value;
}
JNIEXPORT long (JNICALL CallStaticShortMethodAddress) () {
  return (long) CallStaticShortMethod;
}

jint (JNICALL CallStaticIntMethod) (JNIEnv *env, jclass clazz, jmethodID methodID, ...) {
  va_list list;
  jint value;
  va_start(list, methodID);
  value = (*env)->CallStaticIntMethodV(env, clazz, methodID, list);
  va_end(list);
  return value;
}
JNIEXPORT long (JNICALL CallStaticIntMethodAddress) () {
  return (long) CallStaticIntMethod;
}

jlong (JNICALL CallStaticLongMethod) (JNIEnv *env, jclass clazz, jmethodID methodID, ...) {
  va_list list;
  jlong value;
  va_start(list, methodID);
  value = (*env)->CallStaticLongMethodV(env, clazz, methodID, list);
  va_end(list);
  return value;
}
JNIEXPORT long (JNICALL CallStaticLongMethodAddress) () {
  return (long) CallStaticLongMethod;
}

jfloat (JNICALL CallStaticFloatMethod) (JNIEnv *env, jclass clazz, jmethodID methodID, ...) {
  va_list list;
  jfloat value;
  va_start(list, methodID);
  value = (*env)->CallStaticFloatMethodV(env, clazz, methodID, list);
  va_end(list);
  return value;
}
JNIEXPORT long (JNICALL CallStaticFloatMethodAddress) () {
  return (long) CallStaticFloatMethod;
}

jdouble (JNICALL CallStaticDoubleMethod) (JNIEnv *env, jclass clazz, jmethodID methodID, ...) {
  va_list list;
  jdouble value;
  va_start(list, methodID);
  value = (*env)->CallStaticDoubleMethodV(env, clazz, methodID, list);
  va_end(list);
  return value;
}
JNIEXPORT long (JNICALL CallStaticDoubleMethodAddress) () {
  return (long) CallStaticDoubleMethod;
}


void (JNICALL CallStaticVoidMethod) (JNIEnv *env, jclass clazz, jmethodID methodID, ...) {
  va_list list;
  va_start(list, methodID);
  (*env)->CallStaticVoidMethodV(env, clazz, methodID, list);
  va_end(list);
}
JNIEXPORT long (JNICALL CallStaticVoidMethodAddress) () {
  return (long) CallStaticVoidMethod;
}
