.section .data
format_int: .string "%d "
format_last: .string "%d"
format_newline: .string "\n"

.section .bss
stack: .skip 400000000
result: .skip 400000000

.section .text

.global main

main:
	mv s0, a0			# we will use atoi to process the CLAs for array values. 
						# So t0(...) will be clobbered.
						# That's why we will use s0(...) instead
	mv s1, a1
	mv s10, s0          # copy of n (argc), before decrement
	addi s0, s0, -1     # total = n - 1
	li s5, -1

	nearestLarger:
		beq s0, zero, done	# while(total--), goes from n - 1  to 0
		addi s0, s0, -1		# 
		li t0, 8
		mv s2, s0			# for array offset calculation
		mv s3, s1			# base address of array
		addi s2, s2, 1		# s2 <-- i	# i = total + 1 as indices go from n - 1 to 0, but we want n to 1
		mul s2, s2, t0		# s2 <-- (i) * 8
		add s3, s2, s3		# arr + (i) * 8
		ld s4, 0(s3)		# arr[i] is finally now in s4
		mv a0, s4			# set as parameter
		call atoi			# call atoi
		mv s3, a0

		# note that i == total + 1
		# s0 => used for total
		# s1 => used for base address of array
		# s3 => arr[i] i.e. loaded array value
		# s5 => index of top of stack

		# now: compare array value at the present index with the value in the array 
		# at the index which is currently on top of the stack
		# first load array value of the index on top of the stack

		mv t0, s5			# t0 has top index
		li t1, -1
		bgt t0, t1, stackNotEmpty
		ble t0, t1, stackEmpty

		stackNotEmpty:
			la t0, stack
			li t1, 8
			mul t2, t1, s5      # 8 * top
			add t0, t0, t2      # stack + 8 * top
			ld t6, 0(t0)        # t6 = stack[top]
			mv s6, t6			# save stack[top] value across atoi call
			li t1, 8			# for offset calculation
			mul t2, t1, t6 		# t2 <-- 8 * stack[top]
			add t2, s1, t2		# t2 <-- argv + 8 * stack[top]
			ld t2, 0(t2)		# t2 <-- argv[stack[top]] i.e. the char* pointer
			mv a0, t2			# set as parameter
			call atoi			# call atoi on argv[stack[top]]
			mv t2, a0			# t2 <-- integer value of arr[stack[top]]
			mv t6, s6			# restore stack[top]

			## if arr[stack[top]] > arr[i]:
			# 		load result[i] = top
			# 		push i into stack 

			bgt t2, s3, foundAnswer		# if arr[stack[top]] > arr[i], we found the result for arr[i]
			ble t2, s3, decrementTop	# else, decrement the top
			
			# t6 => stack[top]
			# s5 => top value

			decrementTop:
				addi s5, s5, -1
				li t0, -1
				bgt s5, t0, stackNotEmpty
				ble s5, t0, stackEmpty

		foundAnswer: 
			# we have 2 things to do: update the answer (for present element)
			# and update the stack (for future elements)
			
			# part 1: update the result array
			# result[i] = stack[top] - 1
			la t0, result		# load base address of result array
			mv t1, s0			# contains current total
			# addi t1, t1, 1		# i == total + 1
			li t2, 8			# for offset calculation
			mul t1, t2, t1		# t1 <-- i * 8
			add t0, t1, t0		# t2 <-- result + i * 8
			addi t6, t6, -1		# stack[top] - 1 for zero indexing
			sd t6, 0(t0)		# result[i] = stack[top] - 1

			# part 2: update the stack for future elements
			# stack[++top] = i
			addi s5, s5, 1		# ++top
			la t0, stack		# t0 <-- stack
			mv t2, s5 			# t2 <-- top
			li t1, 8			# for offset calculation
			mul t2, t1, t2 		# t2 <-- 8 * top
			add t0, t0, t2		# t0 <-- stack + 8 * top
			mv t1, s0			# t1 <-- total
			addi t1, t1, 1		# t1 <-- i
			sd t1, 0(t0)		# stack[top] = i			

			j nearestLarger
			
		stackEmpty:
			# we have 2 things to do: update the answer (for present element)
			# and update the stack (for future elements)
			
			# part 1: update the result array
			# result[i] = -1
			la t0, result		# load base address of result array
			mv t1, s0			# contains current total
			# addi t1, t1, 1		# i == total + 1
			li t2, 8			# for offset calculation
			mul t1, t2, t1		# t1 <-- i * 8
			add t0, t1, t0		# t0 <-- result + i * 8
			li t3, -1			# t3 <-- -1
			sd t3, 0(t0)		# result[i] = -1

			# part 2: update the stack for future elements
			# stack[++top] = i
			addi s5, s5, 1		# ++top
			la t0, stack		# t0 <-- stack
			mv t2, s5 			# t2 <-- top
			li t1, 8			# for offset calculation
			mul t2, t1, t2 		# t2 <-- 8 * top
			add t0, t0, t2		# t0 <-- stack + 8 * top
			mv t1, s0			# t1 <-- total
			addi t1, t1, 1		# t1 <-- i
			sd t1, 0(t0)		# stack[top] = i			

			j nearestLarger
			
	done:
		li s4, 0					# iterator k
		addi s9, s10, -1
		printing:
			bge s4, s9, completed	# if k > total, completed
			la t0, result			# load base address of result array
			mv t1, s4				# t1 <-- k
			li t2, 8				# t2 <-- 8
			mul t2, t1, t2			# t2 <-- 8 * k
			add t0, t0, t2			# t0 <-- result + 8 * k
			ld t3, 0(t0)			# t3 <-- result[k]
			mv a1, t3				# a1 <-- t3
			addi t4, s9, -1            # last index = s9 - 1
			beq s4, t4, last_elem

			la a0, format_int
			call printf
			j next

			last_elem:
				la a0, format_last
				call printf

			next:
				addi s4, s4, 1
				j printing


			completed:
				la a0, format_newline
				call printf
				li a0, 0       # exit code 0
				li a7, 93      # syscall number for exit
				ecall