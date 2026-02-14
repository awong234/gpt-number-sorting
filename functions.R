make_prompt = function(n, words_joined) {
    glue::glue(
        "Provide an index for the following numbers indicating their rank position in a sorted list of the same numbers. For example, the index for ten, three, two is 3, 2, 1.

        The list is {n} numbers long. Here is the list:

        {words_joined}"
    )
}

make_rands = function(n) {
    rands = runif(n = n, min = 0, max = 1e5)
    rands_words = xfun::numbers_to_words(rands)
    true_order = rank(rands)
    words_joined = rands_words |> paste0(collapse = "\n")
    prompt = make_prompt(n, words_joined)
    return(list(
        n = n,
        numerals = rands,
        literals = rands_words,
        literals_joined = words_joined,
        prompt = prompt,
        ordering = true_order
    ))
}

chat_output_eval = function(make_rands_output, chat_output) {
    n = make_rands_output$n
    chat_ordering = chat_output$ordering
    true_ordering = make_rands_output$ordering
    # Did it exceed n indices?
    exceeded_n = max(chat_ordering) > n
    # Did it have all indices?
    missing_indices = setdiff(1:n, chat_ordering)
    fabricated_indices = setdiff(chat_ordering, 1:n)
    # Did it make a list that was not n units long?
    length_indices = length(chat_ordering)
    # If the indices line up which elements lined up?
    alignment = chat_ordering == true_ordering
    # What is the distance of error made?
    errdist = chat_ordering - true_ordering
    # Kendall-tau distance
    kendall_corr = cor(true_ordering, chat_ordering, method="kendall")
    list(
        length_indices = length_indices == n,
        missing_indices = missing_indices,
        fabricated_indices = fabricated_indices,
        exceeded_max_index = exceeded_n,
        aligned_indices = alignment,
        error_distance = errdist,
        kendall_corr = kendall_corr
    )
}

decomp_output_evals = function(output_evals) {
    # Proportion of index length correct
    p_good_n = mean(sapply(output_evals, \(x) x$length_indices))
    # Proportion of missing indices present
    p_any_missing_indices = mean(sapply(output_evals, \(x) length(x$missing_indices) != 0))
    # Proportion of fabricated indices present
    p_any_fabricated_indices = mean(sapply(output_evals, \(x) length(x$fabricated_indices) != 0))
    p_exceeded_max_index = mean(sapply(output_evals, \(x) x$exceeded_max_index))
    p_aligned = mean(sapply(output_evals, \(x) all(x$aligned_indices)))
    kendall_corr = sapply(output_evals, \(x) x$kendall_corr)

    return(list(
        p_good_n = p_good_n,
        p_any_missing_indices = p_any_missing_indices,
        p_any_fabricated_indices = p_any_fabricated_indices,
        p_exceeded_max_index = p_exceeded_max_index,
        p_aligned = p_aligned,
        kendall_corr = kendall_corr
    ))
}
