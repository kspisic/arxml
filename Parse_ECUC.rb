#!/usr/bin/ruby -w

require 'nokogiri'

class Nokogiri::XML::Document
  def find_shortpath_node(short_path_ref)
    
    path_array = short_path_ref.split("/").reject(&:empty?)
    x = self
    
    path_array.each { |step|
      x = x.xpath("././/SHORT-NAME[text()='#{step}']/..")
    }
    
    return x
  end
  
  def get_frame_id_of_pdu(pdu_short_path_ref)
    frame_name = pdu_short_path_ref.split("/").last
    node = self.xpath("//CAN-FRAME-TRIGGERING/FRAME-REF[contains(.,'#{frame_name}')]/../IDENTIFIER")
    return node.text.to_i.to_s(16)
  end
  
  def get_cycle_time_of_pdu(pdu_short_path_ref)
    node = self.find_shortpath_node(pdu_short_path_ref)
    return node.at("I-PDU-TIMING-SPECIFICATION/CYCLIC-TIMING/REPEATING-TIME/VALUE").text
  end

end


arxml = Nokogiri::XML(File.open(ARGV[0]))

arxml.remove_namespaces!

puts "File: #{ARGV[0]}\n\n"

subcon = arxml.find_shortpath_node("Com/ComConfig").xpath("SUB-CONTAINERS/CONTAINER")

x=0
subcon.each do |con|
	if con.xpath("SHORT-NAME").text.include? "Derived_ComGwMapping"
		x += 1
		a = con.xpath("SUB-CONTAINERS/CONTAINER[SHORT-NAME='ComGwSource']/SUB-CONTAINERS/CONTAINER[SHORT-NAME='ComGwSignal']//VALUE-REF").text.gsub("/ActiveEcuC/Com/ComConfig/", "")
		b = con.xpath("SUB-CONTAINERS/CONTAINER[SHORT-NAME='ComGwDestination']/SUB-CONTAINERS/CONTAINER[SHORT-NAME='ComGwSignal']//VALUE-REF").text.gsub("/ActiveEcuC/Com/ComConfig/", "")
		puts a + "-->" + b
	end
end

puts "\nTotal Signal Routing Count: #{x}"
