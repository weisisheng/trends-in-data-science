topicWords <- function(input, output, session, inputData){
  output$table <- renderTable({
    inputData()[,.(Topic, `Top Words`)]
  })
  
}


