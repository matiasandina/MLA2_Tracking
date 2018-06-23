


df <- read.csv(file = 'Annotator/data/df.csv', stringsAsFactors = F)


# Set the behavior levels
behaviors_to_keep <- factor(c('Hover-over', 'Nesting', 'Retrieving',
                       'Self-Groom', 'Snif', 'Rearing'), 
                       levels=c('Retrieving', 'Hover-over', 
                                'Nesting', 'Snif', 'Rearing', 'Self-Groom'))

df$behavior <- factor(df$behavior, levels=levels(behaviors_to_keep))


duration_plot <- ggplot(filter(df, behavior %in% behaviors_to_keep),
                         aes(behavior, duration, fill=Group)) +
                    geom_boxplot(lwd=0.7, color='gray50') +
                    scale_fill_manual(values = c("white", "black"))+
                    geom_point(size= 3, position = position_dodge(.75)) +
                    geom_point(size= 3, shape = 1, position=position_dodge(.75),
                              colour = "white")+
#                    theme_classic() +
                    theme(text = element_text(size=20),
                          legend.position = 'bottom') +
                    xlab('') + ylab('Duration (frames)')


snif_plot <- ggplot(filter(df, behavior == "Snif"),
                    aes(Group, latency, color=Group)) +
              stat_summary(fun.y = median, fun.ymin = median,
               fun.ymax = median, geom = "crossbar",
               color = "gray50", size = 0.5, width=0.5) +
              geom_point(size=2, alpha=0.8) + 
              geom_point(shape=1, size=2, color='black')+
              scale_color_manual(values=c('white', 'black')) + 
              xlab('') + ylab('Latency to sniff pup (frames)') +
              theme(text = element_text(size=20)) +
              theme(legend.position = 'none')+
              theme(axis.line.x = element_line(color="black", size = 1))
            



cowplot::plot_grid(duration_plot, snif_plot, labels = 'AUTO',
                  rel_widths = c(2, 1), axis='b', align = 'h')




### Stats #####



df_stats <- filter(df, behavior %in% behaviors_to_keep)


library(lme4)

mod1 <- lmer(duration ~ behavior*Group + (1|RatID), data=df_stats)
mod2 <- lmer(duration ~ behavior + Group + (1|RatID), data = df_stats)

df_stats$inter <- interaction(df_stats$Group, df_stats$behavior)

library(lme4)

# Use factor interactions for the model
mod1 <- lmer(duration ~ inter + (1|RatID), data=df_stats)

summary(mod1)

# Assumptions
e <- resid(mod1) # residuos de pearson
pre <- predict(mod1) #predichos
par(mfrow = c(1, 2))
plot(pre, e, xlab="Fitted", ylab="Residuals",
     main="Residuals vs fitted", cex.main=.8 )
abline(0,0)
qqnorm(e, cex.main=.8)
qqline(e)
par(mfrow = c(1, 1))
shapiro.test(e)

##################################
# Fixed effects

# Just the random intercept 
m0 <- lmer(duration ~ (1|RatID), data=df_stats)
anova(m0, mod1) # compare against null model
AIC(m0, mod1) 

library(multcomp)
# Multiple Tukey comparisons
comp_model <- glht(mod1, linfct=mcp(inter ="Tukey"))
summary(comp_model)
cld(comp_model) # letras de significaci?n




plot(mod1)


# Sniffing latency
car::leveneTest(latency~Group, data=filter(df_stats, behavior=="Snif"))

# Sniffing not significant
t.test(latency~Group, data=filter(df_stats, behavior=="Snif"))

# Sniffing duration
car::leveneTest(duration~Group, data=filter(df_stats, behavior=="Snif"))

# Sniffing not significant
t.test(duration~Group, data=filter(df_stats, behavior=="Snif"))

wilcox.test(duration~Group, data=filter(df_stats, behavior=="Snif"))
