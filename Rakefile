def safe_load_lib(library)
  require library
rescue LoadError, NameError => e
  puts "Could not load #{library}, (#{e})"
end

safe_load_lib('rspec/core/rake_task')
safe_load_lib('ruby-lint/rake_task')
safe_load_lib('reek/rake/task')
safe_load_lib('flog_task')

RSpec::Core::RakeTask.new(:spec)

RubyLint::RakeTask.new do |t|
  t.name = 'lint'
  t.files = ['./libraries', './recipes', './resources', './providers']
end

Reek::Rake::Task.new do |t|
  t.fail_on_error = true
  t.verbose = true
end

FlogTask.new

task default: %w(spec lint reek flog)
