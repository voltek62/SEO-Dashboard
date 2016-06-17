# SEO-Dashboard
 SEO Dashboard using R and ScreamingFrog for Reporting and Monitoring 

Read more : 
- https://data-seo.com/2016/05/04/dashboard-seo-active-page/
- https://data-seo.com/2016/06/05/dashboard-seo-part-2/
- https://data-seo.com/2016/06/17/dashboard-seo-part-3-tutorial-paaslogs-for-log-file-analyser/


----------------------
Paaslogs Configuration

**Input section**

input {
  beats {
      port => 5044
          ssl => true
              ssl_certificate => "/etc/ssl/private/server.crt"
              ssl_key => "/etc/ssl/private/server.key"
   }
}

**Filter section**

filter {
    mutate {
        rename => {
             "source" => "filename"
        }
    }
      
    if [type] == "apache" {  
      mutate {
          add_field => { 
                 "section" => "nohtml"
                 "active" => "FALSE"
           }
        }
       grok {
           match => { "message" => "%{OVHCOMMONAPACHELOG}" }
           patterns_dir => "/opt/logstash/patterns"
       }
       if ("_grokparsefailure" in [tags]) {
           mutate {
              remove_tag => [ "_grokparsefailure" ]
            }
           grok {
              match => [ "message", "%{OVHCOMBINEDAPACHELOG}" ]
              patterns_dir => "/opt/logstash/patterns"
             }
        }
        elasticsearch { 
          hosts => "laas.runabove.com" 
          index => "logsDataSEO" 
          user => "ra-logs-XXX" 
          password => "2OkHXXXXXXX"        
          ssl => true 
          query => 'type:csv AND request:"%{[request]}"'
          fields => [["section","section"],["active","active"],["speed","speed"],["compliant","compliant"],["depth","depth"],["inlinks","inlinks"],["outlinks","outlinks"],["status_title","status_title"],["status_description","status_description"],["status_h1","status_h1"],["group_inlinks","group_inlinks"],["group_wordcount","group_wordcount"]]
        }
       dns {
          action => "replace"
          reverse => [ "clientip" ]
       }
       if [clientip] =~ /googlebot.com/ { 
          mutate {
             add_field => { "bot" => "google" }
         }
       }
      if [clientip] =~ /search.msn.com/ { 
         mutate {
            add_field => { "bot" => "bing" }
         }
      }
    }
    if [type] == "csv" {
        csv {
            columns => ["request", "section","active", "speed", "compliant","depth","inlinks","outlinks","status_title","status_description","status_h1","group_inlinks","group_wordcount"]
            separator => ";"
        } 
    }
}


**Custom grok patterns**

OVHCOMMONAPACHELOG %{IPORHOST:clientip} %{USER:ident} %{USER:auth} \[%{HTTPDATE:timestamp}\] "(?:%{WORD:verb} %{NOTSPACE:request}(?: HTTP/%{NUMBER:httpversion_num:float})?|%{DATA:rawrequest})" %{NUMBER:response_int:int} (?:%{NUMBER:bytes_int:int}|-)
OVHCOMBINEDAPACHELOG %{OVHCOMMONAPACHELOG} "%{NOTSPACE:referrer}" %{QS:agent}


---------------------------------



