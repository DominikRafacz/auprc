#' Calculates AUPRC measure
#' @param prob `numeric` vector of probabilities of belonging to class `positive_value`
#' @param y_truth vector of "true" values of response vector
#' @param positive_value which class from `y_truth` should be treated as positive
#' @return Value of area under precision-recall curve
#' @importFrom dplyr `%>%`
#' @export
auprc <- function(prob, y_truth, positive_value) {
  calculate_measures_by_threshold(prob, y_truth, positive_value) %>%
    calculate_area_under_curve()
} 

#' Draws AUPRC curve
#' @inheritParams auprc
#' @return plot of precision-recall curve
#' @importFrom dplyr `%>%`
#' @importFrom ggplot2 ggplot geom_line aes xlim ylim
#' @export
precision_recall_curve <- function(prob, y_truth, positive_value) {
  calculate_measures_by_threshold(prob, y_truth, positive_value) %>%
    ggplot(aes(x = rec, y = prec, color = thresh)) +
    geom_line() +
    xlim(c(0, 1)) +
    ylim(c(0, 1))
} 

#' @importFrom dplyr mutate
calculate_measures_by_threshold <- function(prob, y_truth, positive_value) {
  real_positives <- sum(y_truth == positive_value)
  is_positive_value <- y_truth == positive_value
  
  as.data.frame(t(sapply(seq(0, 1, length.out = 10000), function(thresh) {
    true_positives <- sum((prob >= thresh) & is_positive_value)
    det_positives <- sum(prob >= thresh)
    c(thresh = thresh, 
      prec = true_positives / det_positives, 
      rec = true_positives / real_positives)
  }))) %>%
    mutate(prec = ifelse(is.nan(prec), 1, prec))
}

#' @importFrom dplyr `%>%` group_by arrange slice ungroup mutate summarise pull
calculate_area_under_curve <- function(measures_by_thresholds) {
  measures_by_thresholds %>% 
    group_by(rec) %>%
    arrange(prec) %>%
    arrange(rec) %>%
    slice(1) %>%
    ungroup() %>% 
    mutate(area = prec * (rec - c(0, rec)[-(nrow(.) + 1)])) %>%
    summarise(area = sum(area)) %>%
    pull(area)
}