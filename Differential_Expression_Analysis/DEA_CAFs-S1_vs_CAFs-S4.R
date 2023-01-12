library(limma)
library(umap)
library(xlsx)
library(readxl)
library(dplyr)

Processed_data <- read.delim("raw_count_Filtered_CAF-S1_S4_BC_47samples_annotated.txt")

df_filter=Processed_data[,grepl("S1|S4"
                        ,colnames(Processed_data))]


df_filter=log2(df_filter+1)

colnames(df_filter)=c("S1","S4","S1","S4","S1","S4","S1","S4","S1","S4","S1","S4","S1","S1","S4","S1","S4","S4","S1","S4","S1","S4","S1","S4","S1","S4","S1","S4","S1","S1","S1","S1","S4","S1","S4","S1","S4","S1","S4","S1","S1","S4","S1","S1","S1","S1","S1")
rownames(df_filter)=Processed_data$gene

df_gsea=cbind(rownames(df_filter),df_filter)
colnames(df_gsea)[1]="ID"

# assign samples to groups and set up design matrix
gs <- colnames(df_filter)
gs=factor(gs, levels = c("S4","S1") ) #give groups the same names as the condition column names in df filter (for design)
groups <- gs

design <- model.matrix( ~ 0 + groups )
colnames(design) <- levels(gs)
y <- voom(df_filter, design, plot = F)
fit <- lmFit(y, design)  # fit linear model

# set up contrasts of interest and recalculate model coefficients
cts <- paste(groups[1], groups[2], sep="-") #check the groups' order in cts: group 1 VS group 2 (FC > 0 -> over expressed in group 1)
cont.matrix <- makeContrasts(contrasts=cts, levels=design)
fit2 <- contrasts.fit(fit, cont.matrix)

# compute statistics and table of top significant genes
fit2 <- eBayes(fit2)
tT <- topTable(fit2, adjust="BH",number=20000000) #BH adjustment = standard adjustment in DEA = reduce the rate of false positive (other standard: FDR but too much FP)
tT=tT%>%filter(adj.P.Val<0.05 & abs(logFC)> 0.584) #0.584 = log2(1.5) = standard threshold in DEA (log2(2) if more stringent)

write.xlsx(tT, row.names=T,"DEG_RNASeq_CAF_BC.xlsx")


library(EnhancedVolcano)
tT_index = cbind(gene = rownames(tT), tT)
rownames(tT_index)=1:nrow(tT_index)

#Default enhanced volcan plot (pcutoff = 1e-6, FCcutoff = log2FC > abs(2))
EnhancedVolcano(tT_index, x = "logFC", y = "adj.P.Val", lab=tT_index$gene, title = 'CAF-S1 vs. CAF-S4', 
                legendPosition = 'bottom', subtitle = "Total = 3678 DEG")

# create custom key-value pairs for 'high', 'low', 'mid' expression by fold-change
# all DEG
keyvals <- ifelse(
  tT_index$logFC < -0.584, 'royalblue',
  ifelse(tT_index$logFC > 0.584, 'gold',
         'black'))

keyvals[is.na(keyvals)] <- 'black'
names(keyvals)[keyvals == 'gold'] <- 'up-regulated'
names(keyvals)[keyvals == 'black'] <- 'NS'
names(keyvals)[keyvals == 'royalblue'] <- 'down-regulated'

EnhancedVolcano(tT_index, x = "logFC", y = "adj.P.Val", lab=tT_index$gene, title = 'CAF-S1 vs. CAF-S4', 
                legendPosition = 'bottom', subtitle = "Total = 3678 DEG", colCustom = keyvals, FCcutoff = 0.584, pCutoff = 0.05)


# most significant DEG
keyvals <- ifelse(
  tT_index$logFC < -1 & tT_index$adj.P.Val < 1e-5, 'royalblue',
  ifelse(tT_index$logFC > 1 & tT_index$adj.P.Val < 1e-5, 'gold',
         ifelse(tT_index$logFC < -1 & tT_index$adj.P.Val > 1e-5, 'forestgreen',
                ifelse(tT_index$logFC > 1 & tT_index$adj.P.Val > 1e-5, 'forestgreen',
         'black'))))

keyvals[is.na(keyvals)] <- 'black'
names(keyvals)[keyvals == 'gold'] <- 'p-val and Log2 FC'
names(keyvals)[keyvals == 'black'] <- 'NS'
names(keyvals)[keyvals == 'royalblue'] <- 'p-val and Log2 FC'
names(keyvals)[keyvals == 'forestgreen'] <- 'Log2 FC'

EnhancedVolcano(tT_index, x = "logFC", y = "adj.P.Val", lab=tT_index$gene, title = 'CAF-S1 vs. CAF-S4', 
                legendPosition = 'bottom', subtitle = "Total = 3678 DEG", colCustom = keyvals)


# Identify most significant DEG
most_sig_upreg = tT_index[tT_index$logFC < -1 & tT_index$adj.P.Val < 1e-5,]
most_sig_downreg = tT_index[tT_index$logFC > 1 & tT_index$adj.P.Val < 1e-5,]

library(dplyr)
most_sig_all = bind_rows(most_sig_upreg, most_sig_downreg)

write.xlsx(most_sig_all, row.names=T,"Most_significant_DEG_list.xlsx")
