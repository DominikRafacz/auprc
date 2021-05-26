#' Calculates AUPRC measure
#' 
#' @param prob `[numeric]`\cr
#'  A vector of predicted probabilities of belonging to class
#'  `positive_value`.
#' @param y_truth `[any]`\cr
#'  A vector of "true" labels for predicted observations. Each element
#'  should be either `positive_value` or some other value, treated as
#'  (not specified) negative value.
#' @param positive_value `[any(1)]`\cr
#'  Which of the two distinct values from `y_truth` should be treated
#'  as positive.
#' 
#' @return Value of area under precision-recall curve.
#' 
#' @importFrom dplyr `%>%`
#' @export
auprc <- function(prob, y_truth, positive_value) {
  calculate_measures_by_threshold(prob, y_truth, positive_value) %>%
    calculate_area_under_curve()
} 

#' Draws AUPRC curve
#' 
#' @inheritParams auprc
#' 
#' @return Plot of precision-recall curve.
#' 
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

#' @importFrom dplyr `%>%` mutate if_else
calculate_measures_by_threshold <- function(prob, y_truth, positive_value) {
  thresh <- seq(0, 1, length.out = 10001)
  prob <- findInterval(prob,
                       thresh,
                       rightmost.closed = TRUE)
  true_positives <- rep(0, 10001)
  det_positives <- rep(0, 10001)
  is_positive_value <- y_truth == positive_value
  
  for (i in seq_along(is_positive_value)) {
    if (is_positive_value[i]) {
      true_positives[seq_len(prob[i])] <- true_positives[seq_len(prob[i])] + 1
    }
    det_positives[seq_len(prob[i])] <- det_positives[seq_len(prob[i])] + 1
  }
  
  data.frame(
    thresh = thresh,
    prec = true_positives / det_positives,
    rec = true_positives / sum(is_positive_value)
  ) %>%
    mutate(prec = if_else(is.nan(prec), 1, prec))
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