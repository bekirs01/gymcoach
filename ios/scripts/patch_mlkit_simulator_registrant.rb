#!/usr/bin/env ruby
# Patches GeneratedPluginRegistrant.m so ML Kit plugins are skipped on iOS Simulator.
# Flutter regenerates this file on `flutter pub get`; re-apply before each build.

def correctly_patched?(registrant)
  registrant.include?('#if !TARGET_OS_SIMULATOR') &&
    registrant.include?("#if !TARGET_OS_SIMULATOR\n#if __has_include(<google_mlkit_commons/GoogleMlKitCommonsPlugin.h>)") &&
    registrant.include?("#if !TARGET_OS_SIMULATOR\n  [GoogleMlKitCommonsPlugin registerWithRegistrar") &&
    registrant.match?(
      %r{#endif\n\n#if __has_include\(<maplibre_gl/MapLibreMapsPlugin\.h>\)}m
    )
end

def strip_patch(registrant)
  out = registrant.dup
  out = out.gsub(
    "#import \"GeneratedPluginRegistrant.h\"\n#import <TargetConditionals.h>\n",
    "#import \"GeneratedPluginRegistrant.h\"\n"
  )
  out = out.gsub("#import <TargetConditionals.h>\n", '')
  out = out.gsub("#if !TARGET_OS_SIMULATOR\n#if __has_include(<google_mlkit_commons/", '#if __has_include(<google_mlkit_commons/')
  out = out.gsub("#endif\n#endif\n\n#if __has_include(<maplibre_gl/", "#endif\n\n#if __has_include(<maplibre_gl/")
  out = out.gsub("#endif\n#endif\n#endif\n\n#if __has_include(<maplibre_gl/", "#endif\n\n#if __has_include(<maplibre_gl/")
  out = out.gsub("#if !TARGET_OS_SIMULATOR\n  [GoogleMlKitCommonsPlugin", '  [GoogleMlKitCommonsPlugin')
  out = out.gsub(
    "  [GoogleMlKitPoseDetectionPlugin registerWithRegistrar:[registry registrarForPlugin:@\"GoogleMlKitPoseDetectionPlugin\"]];\n#endif\n",
    "  [GoogleMlKitPoseDetectionPlugin registerWithRegistrar:[registry registrarForPlugin:@\"GoogleMlKitPoseDetectionPlugin\"]];\n"
  )
  out
end

def apply_patch(registrant)
  out = registrant.dup
  out = out.sub(
    '#import "GeneratedPluginRegistrant.h"',
    "#import \"GeneratedPluginRegistrant.h\"\n#import <TargetConditionals.h>"
  )
  out = out.sub(
    '#if __has_include(<google_mlkit_commons/GoogleMlKitCommonsPlugin.h>)',
    "#if !TARGET_OS_SIMULATOR\n#if __has_include(<google_mlkit_commons/GoogleMlKitCommonsPlugin.h>)"
  )
  out = out.sub(
    "#endif\n\n#if __has_include(<maplibre_gl/MapLibreMapsPlugin.h>)",
    "#endif\n#endif\n\n#if __has_include(<maplibre_gl/MapLibreMapsPlugin.h>)"
  )
  out = out.sub(
    '  [GoogleMlKitCommonsPlugin registerWithRegistrar:[registry registrarForPlugin:@"GoogleMlKitCommonsPlugin"]];',
    "#if !TARGET_OS_SIMULATOR\n  [GoogleMlKitCommonsPlugin registerWithRegistrar:[registry registrarForPlugin:@\"GoogleMlKitCommonsPlugin\"]];"
  )
  out = out.sub(
    '  [GoogleMlKitPoseDetectionPlugin registerWithRegistrar:[registry registrarForPlugin:@"GoogleMlKitPoseDetectionPlugin"]];',
    "  [GoogleMlKitPoseDetectionPlugin registerWithRegistrar:[registry registrarForPlugin:@\"GoogleMlKitPoseDetectionPlugin\"]];\n#endif"
  )
  out
end

def patch_mlkit_simulator_registrant(ios_dir)
  registrant_path = File.join(ios_dir, 'Runner', 'GeneratedPluginRegistrant.m')
  return unless File.exist?(registrant_path)

  registrant = File.read(registrant_path)
  return if correctly_patched?(registrant)

  registrant = strip_patch(registrant)
  registrant = apply_patch(registrant)
  File.write(registrant_path, registrant)
end

if __FILE__ == $PROGRAM_NAME
  ios_dir = File.expand_path('..', __dir__)
  patch_mlkit_simulator_registrant(ios_dir)
end
