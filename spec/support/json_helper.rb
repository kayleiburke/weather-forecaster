# spec/support/json_helper.rb

module JsonHelper
  def load_json_stub(filename)
    file_path = Rails.root.join('spec', 'support', 'stubs', filename)
    JSON.parse(File.read(file_path))
  end
end
