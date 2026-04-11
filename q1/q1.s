.section .text
.section .data
    best: .word -1

.global make_node
.global insert
.global get
.global getAtMost

# 24 bytes for struct Node
    # 4 bytes for (int) val field
    # 8 bytes for (struct Node*) left field
    # 8 bytes for (struct Node*) right field
make_node:
    addi sp, sp, -16    # allocate space on the stack
    sw a0, 0(sp)        # storing int val in the stack
    sd ra, 8(sp)        # storing return address in the stack
    li a0, 24           # amount of space for the struct in the parameter 
    call malloc         # malloc takes the size of struct
                        # malloc returns the pointer to the 24 bytes
    lw t1, 0(sp)        # get the stored int val
    sw t1, 0(a0)        # store int val from byte 0 onwards
    sd zero, 8(a0)      # store NULL for left child from byte 8 onwards
    sd zero, 16(a0)     # store NULL for right child from byte 16 onwards
    ld ra, 8(sp)        # restore return address
    addi sp, sp, 16     # restore stack
    ret                 

insert:
    # addi sp, sp, -128   # enough space for stack
    lw t0, 0(a0)          # t0 has root -> val
    beq a0, zero, newNode # if root == NULL, go to newNode
    bne a0, zero, findNode  # else, find the necessary node

    findNode:
        # int val is at bytes 0-4 of the root
        blt a1, t0, goLeft      ## if key is less than val of root, go left
        bge a1, t0, goRight     ## if key is greater than / equal to val of root, go right
            goLeft:             ## if key is less than val of root, go left
                addi sp, sp, -24
                sd a0, 0(sp)    # store root pointer
                sd ra, 8(sp)    # store return address
                mv t0, a0       # value of a0 in t0
                ld a0, 8(a0)    # new parameter = root -> left, a1 is untouched
                call insert     # call insert
                ld t0, 0(sp)    # load root pointer
                ld ra, 8(sp)    # load return address
                sd a0, 8(t0)    # return value is assigned to the left child
                mv a0, t0
                addi sp, sp, 24 # restore stack pointer
                ret
                
            goRight:
                addi sp, sp, -24
                sd a0, 0(sp)    # store root pointer
                sd ra, 8(sp)    # store return address
                mv t0, a0       # value of a0 in t0
                ld a0, 16(a0)   # new parameter = root -> right, a1 is untouched
                call insert     # call insert
                ld t0, 0(sp)    # load root pointer
                ld ra, 8(sp)    # load return address
                sd a0, 16(t0)   # return value is assigned to the left child
                addi sp, sp, 24 # restore stack pointer
                mv a0, t0
                ret
                
    newNode:            # a new node must be made
        addi sp, sp, -16
        sd a0, 0(sp)    # save return value of caller insert
        sd ra, 8(sp)    # save return address of caller insert
        mv a0, a1       # move key to a0
        call make_node  # call make_node function
                        # it will return the address of the new node
                        # restore stack 
        ld ra, 8(sp)
        addi sp, sp, 16 # reset sp
        ret             # return
    
    ret

get:
    beq a0, zero, notPresent
    lw t0, 0(a0)
    beq t0, a1, Found
    blt a1, t0, Left
    blt t0, a1, Right

    notPresent:
        li a0, 0
        ret
    
    Found:
        # found the necessary node, return as it is
        ret

    Left:
        addi sp, sp, -16
        sd ra, 0(sp)
        ld a0, 8(a0)
        call get
        ld ra, 0(sp)
        addi sp, sp, 16
        ret

    Right:
        addi sp, sp, -16
        sd ra, 0(sp)
        ld a0, 16(a0)
        call get
        ld ra, 0(sp)
        addi sp, sp, 16
        ret

getAtMost:
	la t0, best		# load address of global 'best' in t0
	li t1, -1
	sw t1, 0(t0)

getAtMostHelper:
    beq a1, zero, reachedNull
    bne a1, zero, searchTree

    reachedNull:
        la t0, best
        lw a0, 0(t0)
        ret 

    searchTree:
        addi sp, sp, -16
        sd ra, 0(sp)    # save return address in stack
        sd a1, 8(sp)    # save previous root
		ld a1, 8(a1)	# load root -> left in a0
		call getAtMostHelper	# call on left child

		ld a1, 8(sp)
		ld ra, 0(sp)
		addi sp, sp, 16

		ld t0, 0(a1)	# load root -> val in temporary register
		la t1, best		# load address of global 'best' in t1
		lw t1, 0(t1)	# value of best loaded in t1
		bgt t0, a0, returnNow	# if root -> val > val, go to returnNow
		ble t0, a0, newBest

		addi sp, sp, -16	# increment stack pointer again
		sd ra, 0(sp)    # save return address in stack
		sd a1, 8(sp)    # save previous root
		ld a1, 16(a1)	# load root -> right in a0
		call getAtMostHelper	# call on right child

		ld a1, 8(sp)	# restore original root in register a1
		ld ra, 0(sp)
		la t1, best		# load address of global 'best' in t1
		lw a0, 0(t1)	# load value at address 'best' in a0

		addi sp, sp, 16	# restore stack pointer fully
		ret

		newBest:
			ld t0, 0(a1)	# load root -> val in temporary register
			la t1, best		# load address of global 'best' in t1
			sw t0, 0(t1)		# store root -> val in best
		
		returnNow:
			la t1, best		# load address of global 'best' in t1
			lw a0, 0(t1)		# move this to a0
			ret
		