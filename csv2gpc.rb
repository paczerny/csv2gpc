#!/bin/ruby

# Script converts bank statement from .csv to .gpc
# Warning Script can't handle text before header of the csv file
# User need to fill USER SETUP section for the specific bank
# Supported banks are CSOB, KB, Moneta
# Encoding of the input file must be UTF-8.
# Use csv2gpc.sh to convert from from cp1250 and get result in the same encoding

# -*- encoding : utf-8 -*-
require 'date'
require 'digest/md5'
require 'csv'

records = Array.new

if ARGV.length != 2
	puts "Usage: ruby csv2gpc infile_name.csv outfile_name.gpc"
	exit -1
end

file_in = ARGV[0]
file_out = ARGV[1]

CSOB = {
	:nazev => 'název účtu',
	:cu => 'číslo účtu',
	:datum_operace => 'datum zaúčtování',
	:castka => 'částka platby',
	:mena => 'měna platby',
	:zustatek => 'zůstatek',
	:ks => 'konstantní symbol/kód poplatku',
	:vs => 'variabilní symbol/reference',
	:ss => 'specifický symbol',
	:oznaceni_operace => 'popis transakce',
	:nazev_protiuctu => 'protistrana',
	:protiucet => 'účet protistrany',
	:poznamka => 'poznámka'
}

KB = {
	:datum_operace => 'Datum splatnosti',
	:castka => 'Částka',
	:mena => 'Originální měna',
	:zustatek => '',
	:ks => 'KS',
	:vs => 'VS',
	:ss => 'SS',
	:oznaceni_operace => 'Identifikace transakce',
	:nazev_protiuctu => 'Název protiúčtu',
	:protiucet => 'Protiúčet a kód banky',
	:poznamka => 'Popis příkazce'
}

Moneta = {
	:cu => 'Číslo účtu',
	:datum_operace => 'Odesláno',
	:castka => 'Částka',
	:mena => 'Měna',
	:zustatek => '',
	:ks => 'Konstantní symbol',
	:vs => 'Variabilní Symbol',
	:ss => 'Specifický Symbol',
	:oznaceni_operace => 'Popis 1',
	:nazev_protiuctu => 'Název protiúčtu',
	:banka_protiuctu => 'Banka protiúčtu',
	:protiucet => 'Číslo protiúčtu',
	:poznamka => 'Poznámka'
}

######## USER SETUP These lines must be set by user ###############
field_ids = Moneta	# Specify the bank

nazev_uctu = "UL COLOR S.R.O." # Use this if the csv doesn't containt the account name
cislo_uctu = "43-9137840247"	# Use this if the csv doesn't containt the account number
######## End of USER SETUP ###############

# Read and parse csv file
puts "IN file #{file_in}, OUT file #{file_out}"

csv_text = File.read(file_in)
csv = CSV.parse(csv_text, :headers => true, :col_sep => ';')
puts "Number of lines in csv: #{csv.length}"

csv.each do |row|
	nazev_uctu = row[field_ids[:nazev]].strip unless field_ids[:nazev].nil?
	cislo_uctu = row[field_ids[:cu]][/^([0-9]+)\/.*$/, 1] unless field_ids[:nazev].nil?

	current_record = Hash.new
	current_record[:datum_operace] = row[field_ids[:datum_operace]]
	current_record[:castka] = row[field_ids[:castka]].strip.gsub(/\\/, '')
	current_record[:mena] = row[field_ids[:mena]] || 'CZK'
	current_record[:zustatek] = row[field_ids[:zustatek]] || ''
	current_record[:ks] = row[field_ids[:ks]] || '0'
	current_record[:vs] = row[field_ids[:vs]] || '0'
	current_record[:ss] = row[field_ids[:ss]] || '0'
	current_record[:oznaceni_operace] = row[field_ids[:oznaceni_operace]] || ''
	current_record[:nazev_protiuctu] = row[field_ids[:nazev_protiuctu]] || ''
	current_record[:protiucet] = row[field_ids[:protiucet]] || ''
	if current_record[:protiucet] == '0' then
		current_record[:protiucet] = ''
	else
		current_record[:protiucet] = current_record[:protiucet] + '/' + row[field_ids[:banka_protiuctu]] unless field_ids[:banka_protiuctu].nil?
	end

	current_record[:poznamka] = row[:poznamka] || ''

	records << current_record
end

puts "Nazev účtu: #{nazev_uctu}, číslo: #{cislo_uctu}"

oldest = nil
newest = nil

records.each do |record|
	#record[:poznamka] = record[:poznamka].gsub /\s+/, ' '

	#record[:date] = Date.strptime record[:datum_operace], '%d/%m/%Y'
	record[:date] = Date.strptime record[:datum_operace], '%d.%m.%Y'

	# puts '---- Debug output ----'
	# puts cislo_uctu
	# puts record[:protiucet]
	# puts record[:datum_operace]
	# puts record[:castka]
	# puts record[:mena]
	# puts record[:vs]
	# puts record[:nazev_protiuctu]
	# puts record[:oznaceni_operace]
	# puts record[:zustatek]
	# puts '----'
	record[:record_id] = cislo_uctu + record[:protiucet] + record[:datum_operace] + record[:castka] +
	             record[:mena] + record[:vs] + record[:nazev_protiuctu] + record[:oznaceni_operace]  + record[:zustatek]

	record[:hash] = Digest::SHA256.hexdigest(record[:record_id]).hex().to_s(10)[0..12]

	d = record[:date]

	record[:ddmmyy] = d.strftime '%d%m%y'

	if oldest.nil? or d < oldest
		oldest = d
	end

	if newest.nil? or d > newest
		newest = d
	end
end

puts "oldest date #{oldest}, newest #{newest}"
puts "Warning number of records (#{records.length}) diffs " \
	"from csv size (#{csv.length}) " if records.length != csv.length

records.sort! {|a, b| a[:date] <=> b[:date]}


ddmmyy =  oldest.strftime '%d%m%y'
stary_zustatek = "0".rjust 14, '0'
stary_zustatek_znamenko = '+'
novy_zustatek = stary_zustatek
novy_zustatek_znamenko = '+'
obraty_debet = stary_zustatek
obraty_debet_znak = '0' #muze byt '0' nebo '-'
obraty_kredit = stary_zustatek
obraty_kredit_znak = obraty_debet_znak
datum_vyuctovani = newest.strftime '%d%m%y'
por_cislo_vypisu = '000'
pad = 'KB'.ljust(14, ' ')
CRLF="\r\n"
gpc_header  = "074" + cislo_uctu.rjust(16, '0')  + nazev_uctu.rjust(20, ' ') +
          ddmmyy+stary_zustatek + stary_zustatek_znamenko+ novy_zustatek + novy_zustatek_znamenko+
          obraty_debet + obraty_debet_znak + obraty_kredit + obraty_kredit_znak + por_cislo_vypisu +
          datum_vyuctovani + pad + CRLF

if gpc_header.length != 130
	puts "header has invalid length " + gpc_header.length
	exit -1
end


f = File.open(file_out, 'w')

f.write gpc_header

records.each do |record|

	protiucet_cislo = record[:protiucet][/^([0-9]+)\//, 1]
	protiucet_cislo = '' if protiucet_cislo.nil?

	protiucet_kod_banky = record[:protiucet][/^[0-9]+\/([0-9]+)$/, 1]
	protiucet_kod_banky = '' if protiucet_kod_banky.nil?

	record[:castka] = format("%.2f", record[:castka].gsub(',','.'))
	castka = record[:castka][/-?([0-9\.\,]+)$/, 1].gsub('.', '').gsub(',', '').rjust(12, '0')

	debet_kredit = '2'
	debet_kredit = '1' if record[:castka][0] === '-'

	vs = record[:vs].rjust(10, '0')
	ks = record[:ks].rjust(4, '0')[0..3]
	ss = record[:ss].rjust(10, '0')

	# puts protiucet_cislo:protiucet_cislo
	# puts castka:castka
	# puts protiucet_kod_banky:protiucet_kod_banky
	# puts vs:record[:vs]
	# puts ks:record[:ks]
	# puts ss:record[:ss]
	# puts oznaceni_operace:record[:oznaceni_operace]
	popis = record[:poznamka] + record[:nazev_protiuctu] + " " + record[:oznaceni_operace]
	# popis = popis.unpack("U*").map{|c|c.chr rescue '_' }.join # This breaks UTF8 symbols
	popis = popis.ljust(20, ' ')[0..19]
	# puts popis
	mena  = '0203'
	record_line = "075" + cislo_uctu.rjust(16, '0') + protiucet_cislo.rjust(16, '0')\
		+ record[:hash] + castka + debet_kredit + vs + protiucet_kod_banky.rjust(6, '0')\
		+ ks + ss + record[:ddmmyy] + popis + "0" + mena + record[:ddmmyy] + CRLF

	# puts "#{record_line}"

	if record_line.length != 130
		puts "record has invalid length #{record_line.length}"
		puts "#{record_line}"
		exit -1
	end

	f.write record_line
end

f.close

puts "#{file_out} wrote OK"