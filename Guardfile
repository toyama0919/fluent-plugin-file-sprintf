guard :rubocop, all_on_start: false, cli: ['-a'], notification: true do
  watch(%r{.+\.rb$})
  watch(%r{.+\.rake$})
  watch('Rakefile')
  watch(%r{(?:.+/)?\.rubocop\.yml$}) { |m| File.dirname(m[0]) }
end
