require 'yaml'
require 'fileutils'

TEST_CASES = [
  {
    csv: 'KB_2024.csv',
    gpc: 'KB_2024.gpc',
    bank: 'KB',
    account_name: 'UL COLOR S.R.O.',
    account_number: '43-9137840247'
  },
  {
    csv: 'Pohyby_raif_2024.csv',
    gpc: 'Pohyby_raif_2024.gpc',
    bank: 'Raiffeisenbank',
    account_name: 'Pechtik, s.r.o.',
    account_number: '1573055003'
  },
  {
    csv: 'Moneta_2025.csv',
    gpc: 'Moneta_2025.gpc',
    bank: 'Moneta',
    account_name: 'UL COLOR S.R.O.',
    account_number: '43-9137840247'
  }
]

def run_test(test_case)
  puts "Testing #{test_case[:csv]}..."

  # Load base config to get bank formats
  base_config = YAML.load_file('config.yml')
  
  # Create temporary config
  test_config = {
    'current_setup' => {
      'bank' => test_case[:bank],
      'account_name' => test_case[:account_name],
      'account_number' => test_case[:account_number]
    },
    'bank_formats' => base_config['bank_formats']
  }
  
  config_path = "tmp_config_#{test_case[:bank]}.yml"
  File.write(config_path, test_config.to_yaml)
  
  output_gpc_utf8 = "tmp_output_#{test_case[:csv]}.utf8.gpc"
  output_gpc = "tmp_output_#{test_case[:csv]}.gpc"
  utf8_csv = "tmp_utf8_#{test_case[:csv]}"
  
  # Check encoding and convert to UTF-8 if needed
  encoding = `file -b --mime-encoding #{test_case[:csv]}`.strip
  if encoding == 'utf-8' || encoding == 'us-ascii'
    puts "Input is #{encoding}, no conversion needed"
    FileUtils.cp(test_case[:csv], utf8_csv)
  else
    puts "Converting input from CP1250 (detected as #{encoding})"
    system("iconv -f cp1250 -t utf-8 #{test_case[:csv]} -o #{utf8_csv}")
  end
  
  # Run conversion
  system("ruby csv2gpc.rb #{utf8_csv} #{output_gpc_utf8} #{config_path}")
  
  # Convert output back to CP1250 for comparison
  system("iconv -f utf-8 -t cp1250 #{output_gpc_utf8} -o #{output_gpc}")
  
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
  File.delete(output_gpc_utf8) if File.exist?(output_gpc_utf8)
  File.delete(output_gpc) if File.exist?(output_gpc)
  File.delete(utf8_csv) if File.exist?(utf8_csv)
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
