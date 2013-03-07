require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'ruby-debug'

KALJAT_URL = "http://www.alko.fi/servlet/Tuotehaku?doHaku=1&_command_=IndexForm.TuoteHaku&Kieli=FI&Tuoteryhma=600&Makutyyppi=&Maa=&Tyyppi=&Rypale=&Hintamin=&Hintamax=&Vuosimin=&Vuosimax=&Ruokajuoma=&Koodi=&VapaaTeksti=&Myyntipakkaus=&Tartyyppi=1&Pullokoko=&Sorttaus=hinta&"
product_html = open(KALJAT_URL)
doc = Nokogiri::HTML(product_html)

product_info = doc.css("input[name=Tuotenumero]").map do |input|	
	{input.attr("value") => input.next_element.attr("value")}
end

results = product_info.each_with_index.map do |pair, i|
	id = pair.keys.first
	name = pair.values.first
	puts "Product #{name} #{i}/#{product_info.length}"

	url = "http://www.alko.fi/servlet/Saatavuus?doHaku=1&Kieli=FI&Tuotenumero=#{id}&KuntaMaakunta=KUNTA_Helsinki"
	doc = Nokogiri::HTML(open(url))
	stocks = doc.css("tr td:first a").map do |outlet|
		stock = outlet.xpath("../../td/b").text
		[outlet.text, id, name, stock]
	end
end

grouped = results.flatten(1).group_by(&:first)

File.open("kaljat.data", "wb") do |file|
   Marshal.dump(grouped, file)
end
