#' Traverse from one or more selected nodes onto adjacent, outward edges
#' @description From a graph object of class \code{dgr_graph} move to
#' outgoing edges from a selection of one or more selected nodes, thereby
#' creating a selection of edges. An optional filter by edge attribute
#' can limit the set of edges traversed to.
#' @param graph a graph object of class \code{dgr_graph} that is created
#' using \code{create_graph}.
#' @param edge_attr an optional character vector of edge attribute values for
#' filtering the node ID values returned.
#' @param search an option to provide a logical expression with a comparison
#' operator (\code{>}, \code{<}, \code{==}, or \code{!=}) followed by a number
#' for numerical filtering, or, a regular expression for filtering the edges
#' returned through string matching.
#' @return a graph object of class \code{dgr_graph}.
#' @export trav_out_edge

trav_out_edge <- function(graph,
                          edge_attr = NULL,
                          search = NULL){

  if (is.null(graph$selection$nodes)){
    stop("There is no selection of nodes available.")
  }

  # Get all paths leading outward from node in selection
  distance_1_paths <-
    get_paths(graph = graph,
              from = graph$selection$nodes,
              distance = 1)

  # if NA returned, then there are no paths outward, so return
  # the same graph object without modifying the node selection
  if (length(distance_1_paths) == 1 & is.na(distance_1_paths)[1]){
    return(graph)
  }

  # For all valid paths returned, extract the nodes traversed to
  for (i in 1:length(distance_1_paths)){

    if (i == 1){
      from_nodes <- vector(mode = "character")
      to_nodes <- vector(mode = "character")
    }

    from_nodes <-
      c(from_nodes,
        distance_1_paths[[i]][1])

    to_nodes <-
      c(to_nodes,
        distance_1_paths[[i]][2])
  }

  # If a search term provided, filter using a logical expression
  # or a regex match
  if (!is.null(search)){

    if (grepl("^>.*", search) | grepl("^<.*", search) |
        grepl("^==.*", search) | grepl("^!=.*", search)){
      logical_expression <- TRUE } else {
        logical_expression <- FALSE
      }

    if (logical_expression){

      for (i in 1:length(from_nodes)){

        if (i == 1){
          nodes_to <- vector(mode = "character")
          nodes_from <- vector(mode = "character")
          column_number <- which(colnames(graph$edges_df) %in% edge_attr)
        }

        if (grepl("^>.*", search)){
          if (as.numeric(get_edge_attr(graph,
                                       from = from_nodes[i],
                                       to = to_nodes[i])[1, column_number]) >
              as.numeric(gsub(">(.*)", "\\1", search))){

            nodes_from <- c(nodes_from, from_nodes[i])
            nodes_to <- c(nodes_to, to_nodes[i])
          }
        }

        if (grepl("^<.*", search)){
          if (as.numeric(get_edge_attr(graph,
                                       from = from_nodes[i],
                                       to = to_nodes[i])[1, column_number]) <
              as.numeric(gsub("<(.*)", "\\1", search))){

            nodes_from <- c(nodes_from, from_nodes[i])
            nodes_to <- c(nodes_to, to_nodes[i])
          }
        }

        if (grepl("^==.*", search)){
          if (as.numeric(get_edge_attr(graph,
                                       from = from_nodes[i],
                                       to = to_nodes[i])[1, column_number]) ==
              as.numeric(gsub("==(.*)", "\\1", search))){

            nodes_from <- c(nodes_from, from_nodes[i])
            nodes_to <- c(nodes_to, to_nodes[i])
          }
        }

        if (grepl("^!=.*", search)){
          if (as.numeric(get_edge_attr(graph,
                                       from = from_nodes[i],
                                       to = to_nodes[i])[1, column_number]) !=
              as.numeric(gsub("!=(.*)", "\\1", search))){

            nodes_from <- c(nodes_from, from_nodes[i])
            nodes_to <- c(nodes_to, to_nodes[i])
          }
        }
      }
    }

    # Filter using a `search` value as a regular expression
    if (logical_expression == FALSE){

      for (i in 1:length(from_nodes)){

        if (i == 1){
          nodes_to <- vector(mode = "character")
          nodes_from <- vector(mode = "character")
          column_number <- which(colnames(graph$edges_df) %in% edge_attr)
        }

        if (grepl(search,
                  get_edge_attr(graph,
                                from = from_nodes[i],
                                to = to_nodes[i])[1, column_number])){

          nodes_from <- c(nodes_from, from_nodes[i])
          nodes_to <- c(nodes_to, to_nodes[i])
        }
      }
    }

    from_nodes <- nodes_from
    to_nodes <- nodes_to
  }

  # if no `from` or `to` nodes returned, then there are no paths
  # outward, so return the same graph object without modifying the
  # node selection
  if (length(from_nodes) == 0 & length(from_nodes) == 0){
    return(graph)
  }

  # Remove the node selection in graph
  graph$selection$nodes <- NULL

  # Update the list of traversals in graph
  graph$traversals <- NULL

  # Update edge selection in graph
  graph$selection$edges$from <- from_nodes
  graph$selection$edges$to <- to_nodes

  return(graph)
}
