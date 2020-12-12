loadInput <- function(name) {
  data <- read.csv(name, header = FALSE)
  data <- data.frame(do.call('rbind', strsplit(as.character(data$V1), '', fixed = TRUE)))
  data <- as.matrix(data)
  apply(data, 1:2, function(e) { switch(e, "." = 0, "L" = 1, "#" = 2) })
}

vectorize1 <- function(data) {
  vec <- as.vector(t(data))
  col <- ncol(data)
  rm <- nrow(data) + 1
  cm <- ncol(data) + 1

  sees <- sapply(seq(length(vec)), function(p) {
    rr <- (p - 1) %/% col + 1
    cc <- (p - 1) %% col + 1

    v <- c()
    for (ri in (((rr - 1):(rr + 1))) %% rm) {
      for (ci in (((cc - 1):(cc + 1))) %% cm) {
        if (ri == 0 | ci == 0 | ri == rr & ci == cc) {
          v <- append(v, 0)
        } else {
          q <- (ri - 1) * col + ci
          v <- append(v, q)
        }
      }
    }
    v
  })

  list(vec = vec, sees = t(sees))
}


vectorize2 <- function(data) {
  vec <- as.vector(t(data))
  col <- ncol(data)
  rm <- nrow(data) + 1
  cm <- ncol(data) + 1

  sees <- sapply(seq(length(vec)), function(p) {
    if (vec[p] == 0) {
      v <- integer(9)
    } else {
      rr <- (p - 1) %/% col + 1
      cc <- (p - 1) %% col + 1
      v <- c()
      for (dr in -1:1) {
        for (dc in -1:1) {
          if (dr == 0 & dc == 0) {
            v <- append(v, 0)
            next
          }

          for (i in seq(length(vec))) {
            ri <- rr + dr * i
            ci <- cc + dc * i
            if (ri <= 0 | ri >= rm | ci <= 0 | ci >= cm) {
              v <- append(v, 0)
              break
            }
            q <- (ri - 1) * col + ci
            if (vec[q] != 0) {
              v <- append(v, q)
              break
            }
          }
        }
      }
    }
    v
  })

  list(vec = vec, sees = t(sees))
}

conv <- function(vec, sees, elem) {
  l <- vec == elem
  sapply(seq(length(vec)), function(i) {
    s <- l[sees[i,]]
    sum(s)
  })
}

iter <- function(vec, sees, tol) {
  co <- conv(vec, sees, 2)
  ((vec == 1) & (co == 0) | (vec == 2) & (co < tol)) + (vec >= 1)
}

task <- function(data, vectorize, tol) {
  vectorized <- vectorize(data)
  vec <-vectorized$vec
  sees <-vectorized$sees

  prev <- 0
  while (!identical(prev, vec)) {
    prev <- vec
    vec <- iter(vec, sees, tol)
  }
  print(sum(vec == 2))
}

input <- commandArgs(TRUE)[1]
data <- loadInput(input)
task(data, vectorize1, 4)
task(data, vectorize2, 5)
