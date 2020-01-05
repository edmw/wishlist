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

# Sort build phases
target_name = 'App'
targets_to_sort = project.native_targets.select { |x| x.name == target_name || target_name.nil? }
phases_to_sort = [Xcodeproj::Project::Object::PBXSourcesBuildPhase, Xcodeproj::Project::Object::PBXCopyFilesBuildPhase, Xcodeproj::Project::Object::PBXResourcesBuildPhase]
targets_to_sort.each do |target|
  phases_to_sort.each do |phase_to_sort|
    target.build_phases.select { |x| x.class == phase_to_sort }.each do |phase|
      phase.files.sort! { |l, r| l.display_name <=> r.display_name }
    end
  end
end

sources_group = project.groups.find do |group|
    group.name == "Sources"
end
sources_group.sort_recursively_by_type()

project.save()

