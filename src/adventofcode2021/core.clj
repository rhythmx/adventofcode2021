(ns adventofcode2021.core)
(require '[clojure.string :as str])

;; Some lib functions that will see a lot of reuse between days

(defn read-all-lines []
  (line-seq (java.io.BufferedReader. *in*)))

(defn parse-int-lines [lines]
  (for [ln lines]
    ;; some of these inputs have text decorating, so regexp the digits only
    (Integer/parseInt (re-find #"\A-?\d+" ln))))

;;                                                ;;
;; Day 1 - detect increasing values in sonar data ;;
;;                                                ;;

;; Return the number of times in the sequence of integers that the value increased in relation to the previous value
(defn detect-increases
  ([nums] (detect-increases nums nil 0))
  ([nums lastnum count]
   (let [num (first nums)
         restnums (rest nums)]
     (cond
       (= num nil) count
       (= lastnum nil) (detect-increases restnums num 0)
       (> num lastnum) (detect-increases restnums num (+ 1 count))
       (<= num lastnum) (detect-increases restnums num count)))))

;; Sum every group of exactly 3 sequential numbers in a list of numbers
(defn take-3groups-and-sum [nums]
    (let [a (first nums)
          b (first (rest nums))
          c (first (rest (rest nums)))]
      (if (not (and a b c))
        ;; base case returns empty list, must have 3 numbers left to sum
        '()
        ;; otherwise add the prepend the 3-group sum to the recursively
        ;; generated rest of the sums
        (cons (+ a b c) (take-3groups-and-sum (rest nums))))))

;;                                  ;;
;; Day 2 - Navigating the submarine ;;
;;                                  ;;

;; Read lines like "forward 1", "down 2" and return array of associatives: [{:op "forward" :arg 1} {:op "down" :arg 2}]
(defn parse-cmd-lines [lines]
  (for [ln lines]
    (let [str-num (str/split ln #" ")]
      {:op (first str-num) :arg (Integer/parseInt (second str-num))})))

;; take the preprocessed commands and calculate the new position/depth it will yield 
(defn process-cmd [pos cmd]
  (case (:op cmd)
    "forward" (update pos :hpos  + (:arg cmd))
    "down"    (update pos :depth + (:arg cmd))
    "up"      (update pos :depth - (:arg cmd))))

;; Process all the commands and return the product of final depth and position
(defn process-cmds [cmds]
  (let [pos (reduce process-cmd {:hpos 0 :depth 0} cmds)]
    (* (:hpos pos) (:depth pos))))

;; take the preprocessed commands and calculate the new position/depth it will yield, this time using the "aiming" method
(defn process-cmd-b [pos cmd]
  (case (:op cmd)
    "forward" (update (update pos :hpos  + (:arg cmd)) :depth + (* (:arg cmd) (:aim pos)) )
    "down"    (update pos :aim + (:arg cmd))
    "up"      (update pos :aim - (:arg cmd))))

;; Process all the commands and return the product of final depth and position, this time using the "aiming" method
(defn process-cmds-b [cmds]
  (let [pos (reduce process-cmd-b {:hpos 0 :depth 0 :aim 0} cmds)]
    (* (:hpos pos) (:depth pos))))

;;                                                         ;;
;; Main - Check your work against the provided inputs here ;;
;;                                                         ;;

(defn -main [& args]
  (case (first args)
    "1a" (println (detect-increases (parse-int-lines (read-all-lines))))
    "1b" (println (detect-increases (take-3groups-and-sum (parse-int-lines read-all-lines))))
    "2a" (println (process-cmds (parse-cmd-lines (read-all-lines))))
    "2b" (println (process-cmds-b (parse-cmd-lines (read-all-lines))))))

