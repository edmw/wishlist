#!/usr/bin/env ruby

require 'xcodeproj'

project = Xcodeproj::Project.open('Wishlist.xcodeproj')

# Add swiftlint script phase to targets
targets_to_lint = project.native_targets.select { |x| x.name == 'App' || x.name == 'Domain' || x.name == 'Library' }
targets_to_lint.each do |target|
  phase = target.new_shell_script_build_phase()
  phase.name = "Lint Sources ..."
  phase.shell_script = %Q(
    if which swiftlint >/dev/null; then
      swiftlint --config .swiftlint.yml lint ./Sources/#{target.name}/
    else
      echo "Warning: SwiftLint not installed!"
    fi
  )
  target.build_phases.move(phase, 0)
end

# Add sourcery script phase to targets
targets_for_sourcery = project.native_targets.select { |x| x.name == 'Domain' }
targets_for_sourcery.each do |target|
  phase = target.new_shell_script_build_phase()
  phase.name = "Generate Sources ..."
  phase.shell_script = %Q(
    if which sourcery >/dev/null; then
      sourcery --sources "./Sources/#{target.name}"/  --templates "./Sources/#{target.name}/[AutoGenerated]/[Templates]"/ --output "./Sources/#{target.name}/[AutoGenerated]"/
    else
      echo "Warning: Sourcery not installed!"
    fi
  )
  target.build_phases.move(phase, 1)
end

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

