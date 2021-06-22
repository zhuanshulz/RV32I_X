/* +++Date last modified: 05-Jul-1997 */

/*
**        A Pratt-Boyer-Moore string search, written by Jerry Coffin
**  sometime or other in 1991.  Removed from original program, and
**  (incorrectly) rewritten for separate, generic use in early 1992.
**  Corrected with help from Thad Smith, late March and early
**  April 1992...hopefully it's correct this time. Revised by Bob Stout.
**
**  This is hereby placed in the Public Domain by its author.
**
**  10/21/93 rdg  Fixed bug found by Jeff Dunlop
*/

#include <stddef.h>
#include <limits.h>

static size_t table[UCHAR_MAX + 1];
static size_t len;
static char *findme;

int my_strlen(const char* src)
{
    int len = 0;
    while(*src++ != '\0')
        len ++;
    return len;
}

int my_strncmp(const char* str1, const char* str2 ,int size) {
	for (int i = 0; i < size; ++i) {
		if (*(str1 + i) > *(str2 + i)) {
			return 1;
		}
		else if (*(str1 + i) < *(str2 + i)) {
			return -1;
		}
		if (*(str1 + i) == 0 || *(str2 + i) == 0) {
			break;
		}
	}
	return 0;
}

/*
**  Call this with the string to locate to initialize the table
*/

void init_search(const char *string)
{
      size_t i;

      len = my_strlen(string);
      for (i = 0; i <= UCHAR_MAX; i++)                      /* rdg 10/93 */
            table[i] = len;
      for (i = 0; i < len; i++)
            table[(unsigned char)string[i]] = len - i - 1;
      findme = (char *)string;
}

/*
**  Call this with a buffer to search
*/

char *strsearch(const char *string)
{
      register size_t shift;
      register size_t pos = len - 1;
      char *here;
      size_t limit=my_strlen(string);

      while (pos < limit)
      {
            while( pos < limit &&
                  (shift = table[(unsigned char)string[pos]]) > 0)
            {
                  pos += shift;
            }
            if (0 == shift)
            {
                  if (0 == my_strncmp(findme,
                        here = (char *)&string[pos-len+1], len))
                  {
                        return(here);
                  }
                  else  pos++;
            }
      }
      return NULL;
}

int main()
{
      char *here;
      char *find_strings[] = {"abb",
			      NULL};
      char *search_strings[] = {"cabbie"
};
      int i;
	  int result, count = 0;
      for (i = 0; find_strings[i]; i++)
      {
		    count++;
            init_search(find_strings[i]);
            here = strsearch(search_strings[i]);
            if (here)
                result++;
      }
      return result + count;
}

