require 'yaml'

class UserMutex
  def initialize(tenant_id)
    @file = File.join(Sinatra::Application.settings.root, 'tmp', "mutex_#{tenant_id.to_i}.txt")
    @data = File.exist?(@file) ? YAML.load_file(@file) : {}
  end

  def set?
    @data.empty?
  end

  def user
    @data[:user]
  end

  def created_at
    @data[:created_at]
  end

  def set_to(new_user)
    @data[:user] = new_user
    @data[:created_at] = Time.now
    File.open(@file, 'w') {|f| f.puts @data.to_yaml }
  end

  def release
    old_user = user
    File.delete(@file)
    @data = {}
    old_user
  end
end
