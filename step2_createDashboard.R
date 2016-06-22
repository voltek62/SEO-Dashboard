#autoinstall packages
packages <- c("dplyr", "ggplot2")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())))  
}

library(dplyr)
library(ggplot2)

urls_cat_statustitle <- filter(urls, grepl(200,`Status Code`)) %>%
  group_by(Category,`Status Title`) %>%
  summarise(count = n())

urls_cat_statusdesc <- filter(urls, grepl(200,`Status Code`)) %>%
  group_by(Category,`Status Description`) %>%
  summarise(count = n())

urls_cat_statush1 <- filter(urls, grepl(200,`Status Code`)) %>%
  group_by(Category,`Status H1`) %>%
  summarise(count = n())

urls_cat_status <- group_by(urls,Category,`Status Code`) %>%
  summarise(count = n()) %>%
  filter(grepl(200,`Status Code`) | grepl(301,`Status Code`) | grepl(302,`Status Code`) | grepl(404,`Status Code`) | grepl(500,`Status Code`))

urls_cat_active <- group_by(urls,Category,Active) %>%
  summarise(count = n()) 

urls_cat_compliant <- group_by(urls,Category,Compliant) %>%
  summarise(count = n())

urls_cat_compliant_statuscode <- group_by(urls,Category,Compliant,`Status Code`) %>%
  summarise(count = n()) %>%
  filter(grepl(200,`Status Code`) | grepl(301,`Status Code`))

urls_cat_level <- group_by(urls,Category,Level) %>%
  summarise(count = n())

urls_cat_speed <- group_by(urls,Category,Speed) %>%
  summarise(count = n()) %>%
  filter(Speed!='NA')

urls_level_sessions <- aggregate(urls$`GA Sessions`, by=list(Level=urls$Level), FUN=sum, na.rm=TRUE)
colnames(urls_level_sessions) <- c("Level","GA Sessions")

urls_cat_gasessions <- aggregate(urls$`GA Sessions`, by=list(Category=urls$Category, urls$Compliant), FUN=sum, na.rm=TRUE)
colnames(urls_cat_gasessions) <- c("Category","Compliant","GA Sessions")

urls_cat_inlinks <- group_by(urls,Category,Inlinks,`Status Code`) %>%
  summarise(count = n()) %>%
  filter(grepl(200,`Status Code`) | grepl(301,`Status Code`))

urls_level_active <- group_by(urls,Level,Active) %>%
  summarise(count = n()) %>%
  filter(Level<12)

urls_status_speed <- group_by(urls,`Status Code`,Speed) %>%
  summarise(count = n())

urls_level_speed <- group_by(urls,Level,Speed) %>%
  summarise(count = n()) %>%
  filter(Level<12,Speed!='NA')

urls_level <- filter(urls, Level<10) %>%
              arrange(`Status Code`)


p <- ggplot(urls_cat_statustitle, aes(x=Category, y=count, fill=`Status Title`) ) +
     geom_bar(stat = "identity", position = "stack") +
     theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
     labs(x = "Section", y ="Crawled URLs") 
     #+ ggtitle("Nombre d'urls crawlés par section et status de la balise title")

ggsave(file="./graphs/urlsBysectionFillstatustitle.png")


p <- ggplot(urls_cat_statusdesc, aes(x=Category, y=count, fill=`Status Description`) ) +
  geom_bar(stat = "identity", position = "stack") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(x = "Section", y ="Crawled URLs") 
  #+ ggtitle("Nombre d'urls crawlés par section et status de la balise description")
  
ggsave(file="./graphs/urlsBystatusFillstatusdescription.png")  
  
p <- ggplot(urls_cat_statush1, aes(x=Category, y=count, fill=`Status H1`) ) +
  geom_bar(stat = "identity", position = "stack") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(x = "Section", y ="Crawled URLs")
  #+ ggtitle("Nombre d'urls crawlés par section et status de la balise H1")

ggsave(file="./graphs/urlsBysectionFillstatush1.png")  


p <- ggplot(urls_level_active, aes(x=Level, y=count, fill=Active) ) +
     geom_bar(stat = "identity", position = "stack") +
     scale_fill_manual(values=c("#e5e500", "#4DBD33")) +
     labs(x = "Depth", y ="Crawled URLs")
     #+ ggtitle("Nombre d'urls crawlés par profondeur et status actif")

ggsave(file="./graphs/urlsBydepthFillactive.png")  

p <- ggplot(urls_cat_active, aes(x=Category, y=count, fill=Active) ) +
     geom_bar(stat = "identity", position = "stack") +
     scale_fill_manual(values=c("#e5e500", "#4DBD33")) +
     theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
     labs(x = "Section", y ="Crawled URLs")
     #+ ggtitle("Nombre d'urls crawlés par section et status actif")

ggsave(file="./graphs/urlsBysectionFillactive.png")

p <- ggplot(urls_cat_inlinks, aes(x=Category, y=count, fill=`Status Code`) ) +
   geom_bar(stat = "identity", position = "stack") +
   scale_fill_manual(values=c("#4DBD33","#e5e500")) +
   theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
   labs(x = "Section", y ="Inlinks")
   #+ ggtitle("Nombre de liens entrants par section et status code")


ggsave(file="./graphs/inlinksBysectionFillcompliant.png")

p <- ggplot(urls_cat_compliant, aes(x=Category, y=count, fill=Compliant) ) +
   geom_bar(stat = "identity", position = "stack") +
   theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
   labs(x = "Section", y ="Crawled URLs")
   #+ ggtitle("Nombre d'urls crawlés par section et compliant")

ggsave(file="./graphs/urlsBysectionFillcompliant.png")

# fill=Speed
p <- ggplot(urls_cat_gasessions, aes(x=Category, y=`GA Sessions`, fill=Compliant) ) +
  geom_bar(stat = "identity", position = "stack") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(x = "Section", y ="Sessions") +
  scale_fill_manual(values=c("#e5e500","#4DBD33"))

  #,"#fc0000","#000000"
  #+ ggtitle("Nombre de sessions par section")

ggsave(file="./graphs/sessionsBysectionFillcompliant.png")

p <- ggplot(urls_cat_status, aes(x=Category, y=count, fill=`Status Code` ) ) +
  geom_bar(stat = "identity", position = "stack") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(x = "Section", y ="Sessions") +
  scale_fill_manual(values=c("#4DBD33","#e5e500","#b5bd33","#fc0033", "#000000"))
  #+ ggtitle("Nombre d'urls crawlés par section et status code")

ggsave(file="./graphs/urlsBysectionFillstatus.png")

p <- ggplot(urls_level_speed, aes(x=Level, y=count, fill=Speed ) ) +
      geom_bar(stat = "identity", position = "stack") +
      theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
      scale_fill_manual(values=c("#4DBD33","#e5e500","#fc0000" ,"#000000")) +
      labs(x = "Profondeur", y ="Crawled URLs")
      #+ ggtitle("Nombre d'urls crawlés par profondeur et temps de chargement")

ggsave(file="./graphs/urlsBydepthFillspeed.png")

p <- ggplot(urls_level_sessions, aes( x=Level, y=`GA Sessions` ) ) +
  geom_bar(stat = "identity", position = "stack") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(x = "Profondeur", y ="GA Sessions")
  #+ ggtitle("Nombre de sessions par profondeur")

ggsave(file="./graphs/sessionsBylevels.png")

p <- ggplot(urls_cat_speed, aes(x=Category, y=count, fill=Speed ) ) +
      geom_bar(stat = "identity", position = "stack") +
      theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
      labs(x = "Section", y ="Crawled URLs") +
      scale_fill_manual(values=c("#4DBD33","#e5e500","#fc0000","#000000"))
      # + ggtitle("Nombre d'urls crawlés par section et temps de chargement")

ggsave(file="./graphs/urlsBysectionFillspeed.png")

p <- ggplot(urls_cat_compliant_statuscode, aes(x=Category, y=count, fill= Compliant ) ) +
       geom_bar(stat = "identity", position = "stack") +
       theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
       facet_grid(`Status Code` ~ .) +
       labs(x = "Section", y ="Crawled URLs") +
       scale_fill_manual(values=c("#e5e500","#4DBD33","#fc0000","#000000"))
       # + ggtitle("Nombre d'urls crawlés par section et compliant")

ggsave(file="./graphs/urlsBysectionFillcompliant.png")


