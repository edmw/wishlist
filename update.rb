#!/usr/bin/env ruby

require 'xcodeproj'

project = Xcodeproj::Project.open('Wishlist.xcodeproj')

# Change deployment target to 10.12 for all build configurations
build_configurations = project.build_configuration_list.build_configurations
for build_configuration in build_configurations
    build_configuration.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '10.12'
end

# Add swiftlint script phase to App target
target = project.targets.select { |target| target.name == 'App' }.first
phase = target.new_shell_script_build_phase()
phase.shell_script = %q(
if which swiftlint >/dev/null; then
  swiftlint
else
  echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
)

project.save()

