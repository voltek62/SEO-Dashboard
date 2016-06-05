# SEO-Dashboard
 SEO Dashboard using R and ScreamingFrog for Reporting and Monitoring 

Read more : 
- https://data-seo.com/2016/05/04/dashboard-seo-active-page/
- https://data-seo.com/2016/06/05/dashboard-seo-part-2/


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


**Custom grok patterns**

OVHCOMMONAPACHELOG %{IPORHOST:clientip} %{USER:ident} %{USER:auth} \[%{HTTPDATE:timestamp}\] "(?:%{WORD:verb} %{NOTSPACE:request}(?: HTTP/%{NUMBER:httpversion_num:float})?|%{DATA:rawrequest})" %{NUMBER:response_int:int} (?:%{NUMBER:bytes_int:int}|-)
OVHCOMBINEDAPACHELOG %{OVHCOMMONAPACHELOG} "%{NOTSPACE:referrer}" %{QS:agent}


---------------------------------



