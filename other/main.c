#include <stdio.h>
#include <fcntl.h>

char file_path[]="/home/petru/text-files";

int main()
{
    
    int fd = open(file_path, O_RDONLY | __O_DIRECTORY);
    if(fd == -1)
    {
        printf("Error");
    }

    
    printf("%d", fd);
    return 0;
}