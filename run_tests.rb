require 'yaml'
require 'fileutils'

TEST_CASES = [
  {
    csv: 'KB_2024.csv',
    gpc: 'KB_2024.gpc',
    bank: 'KB',
    account_name: 'UL COLOR S.R.O.',
    account_number: '43-9137840247',
    input_encoding: 'CP1250'
  },
  {
    csv: 'Pohyby_raif_2024.csv',
    gpc: 'Pohyby_raif_2024.gpc',
    bank: 'Raiffeisenbank',
    account_name: 'Pechtik, s.r.o.',
    account_number: '1573055003',
    input_encoding: 'CP1250'
  },
  {
    csv: 'Moneta_2025.csv',
    gpc: 'Moneta_2025.gpc',
    bank: 'Moneta',
    account_name: 'UL COLOR S.R.O.',
    account_number: '43-9137840247',
    input_encoding: 'UTF-8'
  }
]

def run_test(test_case)
  puts "Testing #{test_case[:csv]}..."

  # Load base config to get bank formats
  base_config = YAML.load_file('config.yml')
  
  # Create temporary config with specific encodings
  test_config = {
    'current_setup' => {
      'bank' => test_case[:bank],
      'account_name' => test_case[:account_name],
      'account_number' => test_case[:account_number],
      'input_encoding' => test_case[:input_encoding],
      'output_encoding' => 'CP1250' # Reference files are CP1250
    },
    'bank_formats' => base_config['bank_formats']
  }
  
  config_path = "tmp_config_#{test_case[:bank]}.yml"
  File.write(config_path, test_config.to_yaml)
  
  output_gpc = "tmp_output_#{test_case[:csv]}.gpc"
  
  # Run conversion - now csv2gpc.rb handles encoding internally
  system("ruby csv2gpc.rb #{test_case[:csv]} #{output_gpc} #{config_path}")
  
  # Compare files
  if File.exist?(output_gpc) && File.exist?(test_case[:gpc])
    if FileUtils.compare_file(output_gpc, test_case[:gpc])
      puts "SUCCESS: #{test_case[:csv]} matches #{test_case[:gpc]}"
      true
    else
      puts "FAILURE: #{test_case[:csv]} output differs from #{test_case[:gpc]}"
      # Show diff if possible
      system("diff #{output_gpc} #{test_case[:gpc]}")
      false
    end
  else
    puts "FAILURE: Output file or reference file missing"
    false
  end
ensure
  # Cleanup
  File.delete(config_path) if File.exist?(config_path)
  File.delete(output_gpc) if File.exist?(output_gpc)
end

all_passed = true
TEST_CASES.each do |test_case|
  all_passed &= run_test(test_case)
end

if all_passed
  puts "\nAll tests passed!"
  exit 0
else
  puts "\nSome tests failed."
  exit 1
end
