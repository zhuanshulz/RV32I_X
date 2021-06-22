#include <string.h>
#include <limits.h>

int my_strlen(const char* src)
{
    int len = 0;
    while(*src++ != '\0')
        len ++;
    return len;
}

int boyermoore_horspool_memmem(const unsigned char* haystack, size_t hlen,
                           const unsigned char* needle,   size_t nlen)
{
    size_t scan = 0;
    size_t bad_char_skip[UCHAR_MAX + 1];
	
    if (nlen <= 0 || !haystack || !needle)
        return 0;
    for (scan = 0; scan <= UCHAR_MAX; scan = scan + 1)
        bad_char_skip[scan] = nlen;
		
    size_t last = nlen - 1;
	
    for (scan = 0; scan < last; scan = scan + 1)
        bad_char_skip[needle[scan]] = last - scan;
		
    while (hlen >= nlen)
    {
        for (scan = last; haystack[scan] == needle[scan]; scan = scan - 1)
            if (scan == 0)
                return 1;

        hlen     -= bad_char_skip[haystack[last]];
        haystack += bad_char_skip[haystack[last]];
    }
 
    return 0;
}

int main()
{
	int here;
    char *find_strings[] = {"abb",
							"acc",
							"acc",
			      NULL};
    char *search_strings[] = {"cabbie",
							"accelerator",
							"abaaaac",
	};
    int i;
	int result = 0;
	int count = 0;
	for (i = 0; find_strings[i]; i++)
	{
		    count++;
            here = boyermoore_horspool_memmem(search_strings[i], my_strlen(search_strings[i]), find_strings[i], my_strlen(find_strings[i]));
            if (here)
                result++;
    }
	return result + count;
}