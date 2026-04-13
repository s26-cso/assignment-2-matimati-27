.section .data
filename: .asciz "input.txt"
mode:     .asciz "r"
yes:  .asciz "Yes\n"
no:   .asciz "No\n"

.section .text
.global main

main:
    addi sp, sp, -16
    sd ra, 0(sp)
    la a0, filename
    la a1, mode
    call fopen
    
    mv s0, a0           # s0 => file pointer
                        # note that a0 <-- file pointer
    li a1, 0            # a1 <-- 0
    li a2, 2            # a2 <-- SEEK_END {code 2}
    call fseek

	mv a0, s0			# a0 <-- file pointer 
	call ftell			

    mv s1, a0			# s1 <-- n
	li s2, 0			# left pointer, l = 0
	addi s3, s1, -1		# right pointer, r = n - 1
	
	# s0 => file pointer
	# s1 => n
	# s2 => l
	# s3 => r

	loop:
		bgt s2, s3, true	# if control flow reaches l > r, then it is a palindrome
							# while(l <= r)
		mv a0, s0			# a0 <-- file pointer
		mv a1, s2			# a1 <-- l
		li a2, 0			# a2 <-- SEEK_SET {code 0}
		call fseek			# fetch 

		mv a0, s0			# a0 <-- file pointer
		call fgetc			# fetch character
		mv s7, a0			# store character string[l] in s7

		mv a0, s0			# a0 <-- file pointer
		mv a1, s3			# a1 <-- r
		li a2, 0			# a2 <-- SEEK_SET {code 0}
		call fseek			# fetch

		mv a0, s0			# a0 <-- file pointer
		call fgetc			# fetch character
		mv s8, a0			# store character string[r] in s8

		bne s7, s8, false
		addi s2, s2, 1		# l++
		addi s3, s3, -1		# r--
		j loop

		false:
			la a0, no
			call printf
			mv a0, s0
			call fclose
			j exit
		
		true:
			la a0, yes
			call printf
			mv a0, s0
			call fclose
			j exit

	exit:
		ld ra, 0(sp)
		addi sp, sp, 16
		ret