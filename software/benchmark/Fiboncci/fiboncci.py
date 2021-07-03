def fibo1(n):
    a, b = 1, 1
    for i in range(n):
        a, b = b, a+b
    return a

print(fibo1(1))