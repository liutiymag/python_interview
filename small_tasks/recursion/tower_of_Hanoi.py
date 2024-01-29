"""
Tower of Hanoi is a mathematical problem where we have three rods and n disks. The goal of this puzzle is to move all the disks to another rod, obeying the following rules:

Move only one disk at a time
You can’t place a larger disk over a smaller disk
The disks are put in ascending order of their size at the start.
"""

def toh(n, start, end, aux):
    if n == 1:
        print("Move disk 1 from", start, "to", end)
        return
    toh(n-1, start, aux, end)
    print("Move disk", n, "from", start, "to", end)
    toh(n-1, aux, end, start)

toh(3, 'A', 'B', 'C')