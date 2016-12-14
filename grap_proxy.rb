#!/usr/bin/env ruby -wKU
#Author m@zcq100.com
#Time 2016-12-14
#Get HTTP form xicidaili.com

require 'open-uri'
require 'net/http'
require 'timeout'

url="http://www.xicidaili.com/"
list=Queue.new
html=open(url) {|f|f.read}

#page ip match
regex=/<tr class="">\s*<td[\s\S]*?><\/td>\s*<td>([\d|.]*?)<\/td>\s*<td>([\d|.]*?)<\/td>\s*<td>(\S*?)<\/td>/
#get proxy list
html.scan(regex).each { |e|
  list<< [e[0],e[1]] 
}

p "Get #{list.size} http server ip."
p "Prepare check them."
#Test Proxy
def test_proxy host,port=80,timeout=10
  result=false
  begin
    result=Timeout::timeout(timeout){
      uri=URI "http://www.baidu.com"
      http=Net::HTTP.new(uri.hostname,uri.port,host,port)
      res=http.get "/"
      p "#{host}:#{port}:Code[#{res.code}]"
    }
  rescue Exception => e
    p "#{host}:#{port} ---#{e.class} "
 end
 result
end

proxy_list2=[]
thrs=[]
list.size.times.each do 
  thrs<<Thread.new do
    while !list.empty? do
      ip=list.pop
      proxy_list2<<[ip[0],ip[1]] if test_proxy(ip[0],ip[1],10)
    end 
  end  
end

thrs.each{|t|t.join}

proxy_list2.each {|x| p x}
p "usefull proxy number:#{proxy_list2.size}"