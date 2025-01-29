This was done using 32bit assembly x86.
For the implementation of this task, we assume that you are part of the development team of a minimal operating system,
the operating system being a software product that deals with the management and
coordinating the activities of a computer system, with a role in mediating access to application programs
to the machine's resources.
Your task is to implement a management component of the storage device (hard disk or SSD), 
and because the project is just at the beginning, we have many assumptions that simplify the development of this product.

There will be two modes of operation that are taken into account, a case in which the memory is linear, one-dimensional,
respectively a case in which the memory is two-dimensional.

The operating system does not have a structure of directories or files, it only has to store files.
In this sense, each file is identified by a descriptor - file-descriptor, unique ID (a natural number between 1
and 255); thus, our system can store a maximum of 255 different files.
