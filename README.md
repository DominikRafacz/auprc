# auprc

You can install this package using

```{r}
devtools::install_github("DominikRafacz/auprc")
```

Two main functionalities of this package are calculating plotting the precision-recall curve and calculating area under it.

```{r}
auprc(prob, y_truth, positive_value)
precision_recall_curve(prob, y_truth, positive_value)
```

This package registers measure for `mlr3` framework. You can access it by using

```{r}
msr("classif.auprc")
```

or 

```{r}
mlr_measures$get("classif.auprc")
```

Important! If you want to make sure that AUPRC for `mlr3` is computed correctly, you have to specify parameter `positive` during creation of new `ClassifTask`.
