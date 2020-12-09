declare -A RULES

while read LINE; do
  H=${LINE% bags contain *}
  T=${LINE#* contain }
  if [[ $T = 'no other bags.' ]]; then
    RULES[$H]=''
  else
    T=${T// bags,/}
    T=${T// bag,/}
    T=${T// bags./}
    T=${T// bag./}
    RULES[$H]=$T
  fi
  #echo "$H: $T"
done < $1

declare -A OUTER
OUTER[shiny gold]=1
SIZE=0

while [[ $SIZE -lt ${#OUTER[@]} ]]; do
  SIZE=${#OUTER[@]}

  for H in "${!RULES[@]}"; do
    T=${RULES[$H]}
    for O in "${!OUTER[@]}"; do
      V=${OUTER[$H]}
      if [[ "$T" == *"$O"* && "$V" -ne 1 ]]; then
#        echo "$O found in $T, adding $H"
        OUTER[$H]=1
      fi
    done
  done
done

#for K in "${!OUTER[@]}"; do
#  echo $K --- ${OUTER[$K]};
#done

echo $(( SIZE - 1))

function cnt() {
  local T=(${RULES[$1]})
#  echo "> $1 ${T[@]}"
  local S=1

  local I=0
  while [[ $I -lt ${#T[@]} ]]; do
    local C=${T[$I]}
    local A=${T[$(( I + 1 ))]}
    local B=${T[$(( I + 2 ))]}

#    echo "i $I $C $A $B"
    cnt "$A $B" O
    S=$(( S + O * C ))
#    echo "= $S"
    I=$(( I + 3 ))
  done

  local -n OUT=$2
  OUT=$S
#  echo "< $1 $OUT"
}


cnt 'shiny gold' O

echo $(( O - 1 ))
