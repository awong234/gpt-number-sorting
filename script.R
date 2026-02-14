import::from("ellmer",
             "chat", "chat_openai", "type_object", "type_array", "type_integer")
import::from("functions.R",
             "make_prompt", "make_rands", "chat_output_eval", "decomp_output_evals")

# Set up

set.seed(1)

item = make_rands(10)
item

# models_openai()
chat = chat_openai(
    system_prompt = "You are an expert mathematician and logician. But, you can only speak using numbers and are exceedingly terse only replying with the solutions asked and no more. Provide no context for your answers, provide no support for your answers, provide only numbers.",
    model = "gpt-5.2"
)

numbers = make_rands(10)

output_type = type_object(
    ordering = type_array(type_integer())
)

res = chat$chat_structured(
    numbers$prompt,
    type = output_type
)

chat_output_eval(numbers, res)

stack_result = function(make_rands_output, chat_output) {
    identical(make_rands_output$ordering, chat_output$ordering)
    rbind(make_rands_output$ordering, chat_output$ordering)
}

stack_result(numbers, res)

# Evaluate a large number of replicates ------------

reps = 50
lots_of_rands = lapply(1:reps, \(x) make_rands(20))
prompts = sapply(lots_of_rands, \(x) x$prompt)

res_many = lapply(1:reps, \(i) {
    chat$chat_structured(
        prompts[i],
        type = output_type
    )
})

output_evals = list()
for (i in 1:reps) {
    output_evals[[i]] = chat_output_eval(lots_of_rands[[i]], res_many[[i]])
}

decomp_output_evals(output_evals)

# fabbed = which(sapply(output_evals, \(x) length(x$fabricated_indices) != 0))
# lots_of_rands[[fabbed]]
# res_many[[fabbed]]

aligned = which(sapply(output_evals, \(x) all(x$aligned_indices)))

output_evals[aligned[1]]
