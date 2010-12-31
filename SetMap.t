// -*-java-*-
changequote(<!,!>)dnl
dnl
dnl // IFMAP/IFSET: true if that type of class is being defined
ifelse(KIND, <!Map!>, <!define(<!IFMAP!>,<!$1!>)!>, <!define(<!IFMAP!>,<!!>)!>)dnl
ifelse(KIND, <!Set!>, <!define(<!IFSET!>,<!$1!>)!>, <!define(<!IFSET!>,<!!>)!>)dnl
dnl
dnl // THISCLASS: name of the class that's being defined
define(<!THISCLASS!>, <!KIND<!!>XKEYTYPE<!!>IFMAP(<!XVALTYPE!>)!>)dnl
dnl
dnl // SETCLASS: name of the complementary Set class, e.g. SetInteger
dnl // for MapInteger*.  Same as THISCLASS for Sets.
define(<!SETCLASS!>, <!Set<!!>XKEYTYPE!>)dnl
dnl
dnl // IFBASIC: true when VALTYPE is intrinsic type or Object;  true also for Sets
ifelse(KIND, <!Map!>,
       <!ifelse(VALTYPE, <!Object!>,
		<!define(<!IFBASIC!>, <!$1!>)!>,
		VALTYPE, XVALTYPE,
		<!define(<!IFBASIC!>, <!!>)!>,
		<!define(<!IFBASIC!>, <!$1!>)!>)!>,
       <!define(<!IFBASIC!>, <!$1!>)!>)dnl
dnl
dnl // IFNBASIC: true when IFBASIC is false and the other way around
ifelse(IFBASIC(<!X!>), <!X!>,
       <!define(<!IFNBASIC!>, <!!>)!>,
       <!define(<!IFNBASIC!>, <!$1!>)!>)dnl
import java.util.Enumeration;

public class THISCLASS {

    /**
     * An array of keys (e.g. [1, 2, 4] means 1, 2 and 4 are in KIND).
     */
    KEYTYPE[] keys;

    /**COUNT is the number of keys in KIND (3 in above case) */
    int count;

IFMAP(<!dnl
    /**
     * An array of values assigned to keys.  Values are given in the
     * same order as in KEYS array.  E.g. [false, false, true] would
     * suggest mapping 1:false, 2:false and 4:true.
     */
    VALTYPE[] values;

!>)dnl
    /**
     * INDEX maps keys to their position in KEYS and VALUES.  INDEX[n]
     * contains position of key n, or -1 if the key isn't in KIND.  In
     * the above case it would look like [-1, 0, 1, -1, 2, -1, -1,
     * ...]
     */
    int[] index;

    private void maybeResize() {
	if (keys == null || count + 1 > keys.length) {
	    int ocapacity = keys == null ? 0 : keys.length;
	    int capacity = keys == null ? 2 : ocapacity * 2;

	    //System.out.println("resize: " + ocapacity + "->" + capacity);
	    KEYTYPE[] nkeys = new KEYTYPE[capacity];
M?	    VALTYPE[] nvalues = new VALTYPE[capacity];

	    for (int i = 0; i < ocapacity; ++i) {
		nkeys[i] = keys[i];
M?		nvalues[i] = values[i];
	    }
	    keys = nkeys;
M?	    values = nvalues;
	}
    }

    private KEYTYPE roundPower2(KEYTYPE key) {
	key |= key >> 1;
	key |= key >> 2;
	key |= key >> 4;
	key |= key >> 8;
	key |= key >> 16;
	++key;
	if (key <= 0)
	    return XKEYTYPE.MAX_VALUE;
	return key;
    }

    private void accomodateKey(KEYTYPE key) {
	if (index == null || index.length <= key) {
	    int oicapacity = index == null ? 0 : index.length;
	    int icapacity = roundPower2(key);
	    //System.out.println("resize index: " + oicapacity + "->" + icapacity);
	    int[] nindex = new int[icapacity];
	    for (int i = 0; i < oicapacity; ++i)
		nindex[i] = index[i];
	    for (int i = oicapacity; i < icapacity; ++i)
		nindex[i] = -1;
	    index = nindex;
	}
    }

    public void clear() {
	keys = null;
M?	values = null;
	index = null;
	count = 0;
    }

    public THISCLASS<!!>() {
	clear();
    }

    public THISCLASS<!!>(THISCLASS copy) {
	clear();
	addAll(copy);
    }

    public static THISCLASS differenceOf(THISCLASS set1, THISCLASS set2) {
	THISCLASS ret = new THISCLASS<!!>();
	if (set1 == set2)
	    return ret;

	KEYTYPE key;
	for (Iterator ve = set1.iterator(); ve.hasMoreElements(); )
	    if (!set2.containsKey(key = ve.nextElement()))
		ret.add(key<!!>IFMAP(<!, ve.getValue()!>));
	return ret;
    }

IFMAP(<!dnl
    public SETCLASS keys() {
	SETCLASS k = new SETCLASS<!!>();
	for (int i = 0; i < count; ++i)
	    k.add(keys[i]);
	return k;
    }

!>)dnl
    public int size() {
	return count;
    }

    public boolean containsKey(KEYTYPE key) {
	if (index != null && key < index.length)
	    return index[key] != -1;
	else
	    return false;
    }

M?  public VALTYPE getValue(KEYTYPE key) {
M?	return values[index[key]];
M?  }

    /**
     * This operation can be used as a "push".  The value is added to
     * the end of the internal queue, and the same key will be
     * answered after the following call to popKey.  This holds UNLESS
     * any removeKey call occurs inbetween, and UNLESS key was present
     * in the set before.
     * XXX This is highly dubious.  Kill it.
     */
    public void add(KEYTYPE key<!!>IFMAP(<!, VALTYPE value!>)) {

	if (key < 0)
	    throw new IllegalArgumentException
		("Can't add negative key to the set.");

	if (!containsKey(key)) {
	    accomodateKey(key);
	    maybeResize();

	    index[key] = count;
M?	    values[count] = value;
	    keys[count++] = key;

	}
    }

    public boolean remove(KEYTYPE key) {
	if (!containsKey(key))
	    return false;

	int idx = index[key];
	index[key] = -1;
	count--;
	if (count > 0 && idx != count) {
	    // move last element to freed index
	    index[keys[count]] = idx;
	    keys[idx] = keys[count];
M?	    values[idx] = values[count];
	}
	return true;
    }

    /** XXX kill also this. */
    public KEYTYPE popKey() {
	KEYTYPE key = keys[count - 1];
	remove(key);
	return key;
    }

    public class Iterator {
	int i = 0;
	private Iterator() {}

    	public boolean hasMoreElements() {
	    return i < count;
	}
	public KEYTYPE nextElement() {
	    return keys[i++];
	}
	public void remove() {
	    THISCLASS.this.remove(keys[i - 1]);
	    --i;
	}
M?	public VALTYPE getValue() {
M?	    return values[i - 1];
M?	}
    }

    public Iterator iterator() {
	return new Iterator();
    }

    public class Entry {
	public final KEYTYPE key;
M?	public final VALTYPE value;
	private Entry(KEYTYPE key<!!>IFMAP(<!, VALTYPE val!>)) {
	    this.key = key;
M?	    this.value = val;
	}
    }

    public Enumeration enumerate() {
	return new Enumeration() {
	    int i = 0;
	    public boolean hasMoreElements() {
		return i < THISCLASS.this.count;
	    }
	    public Object nextElement() {
		int o = i++;
		return new Entry(THISCLASS.this.keys[o]IFMAP(<!,
				 THISCLASS.this.values[o]!>));
	    }
	};
    }

    public boolean containsAll(SETCLASS other) {
	// I can't contain all of the set that is larger than me.
	if (other.count > count)
	    return false;

	for (int i = 0; i < other.count; ++i) {
	    KEYTYPE key = other.keys[i];
	    if (!containsKey(key))
		return false;
	}

	return true;
    }

    public boolean containsAny(SETCLASS other) {
	for (int i = 0; i < other.count; ++i) {
	    KEYTYPE key = other.keys[i];
	    if (containsKey(key))
		return true;
	}

	return false;
    }

IFMAP(<!dnl
    public boolean containsAll(THISCLASS other) {
	return containsAll(other.keys());
    }

    public boolean containsAny(THISCLASS other) {
	return containsAny(other.keys());
    }

!>)dnl
    public void addAll(THISCLASS other) {
	if (this == other)
	    return;
	else
	    for (int i = 0; i < other.count; ++i)
		add(other.keys[i]IFMAP(<!, other.values[i]!>));
    }

    public void removeAll(THISCLASS other) {
	if (this == other)
	    clear();
	else
	    for (int i = 0; i < other.count; ++i)
		remove(other.keys[i]);
    }

    public void retainAll(THISCLASS other) {
	if (this == other)
	    return;
	else
	    for (int i = 0; i < count; ++i) {
		KEYTYPE key = keys[i];
		if (!other.containsKey(key)) {
		    remove(key);
		    --i;
		}
	    }
    }

IFMAP(<!dnl
    private boolean valuesSame(THISCLASS other) {
	for (int i = 0; i < count; ++i) {
	    KEYTYPE key = keys[i];
	    if (getValue(key) != other.getValue(key))
		return false;
	}
	return true;
    }

    // Warning: this checks values with "==" operator, it doesn't call
    // .equals even if the value type is full-fledged object.
    // FIXME???
!>)dnl
    public boolean equals(THISCLASS other) {
	if (this == other)
	    return true;
	else
	    return count == other.count
		&& containsAll(other)
		&& other.containsAll(this)IFMAP(<!
		&& valuesSame(other)!>);
    }

    public int hashCode() {
	int hash = 0;
	if (index != null)
	    for (int i = 0; i < index.length; ++i) {
		int ix = index[i];
		if (ix == -1)
		    continue;
		hash ^= (new XKEYTYPE (keys[ix])).hashCode ();
		hash = (hash << 1) | (hash >>> 31);
	    }
	return hash;
    }

    public String toString() {
	StringBuffer buf = new StringBuffer();
	buf.append('{');
	for (int i = 0; i < count; ++i) {
	    if (i > 0)
		buf.append(", ");
	    buf.append(keys[i])IFMAP(<!.append('=').append(values[i])!>);
	}
	return buf.append('}').toString();
    }


    private static void abort(String message) {
	throw new RuntimeException(message);
    }

    private static void dumpsets(THISCLASS[] sets) {
	for (int i = 0; i < sets.length; ++i)
	    System.out.println("#" + i + " = " + sets[i]);
    }

IFBASIC(<!dnl
    private static int failures = 0;
    private static int totalTests = 0;
    private static void check(boolean condition, String message) {
	if (!condition) {
	    System.out.println("FAIL " + message);
	    ++failures;
	}
	++totalTests;
    }

    public static void main(String[] args) {
	THISCLASS vs = new THISCLASS<!!>();

	vs.hashCode ();

	KEYTYPE[] keys = {2, 4, 50, 8, 9, 10, 15, 20};
IFMAP(<!dnl
	VALTYPE[] values = {ifelse(XVALTYPE, <!Boolean!>,
				   <!true, false, false, false, true, false, true, false!>,
				   XVALTYPE, <!Object!>,
				   <!new Integer(1), "Ahoj", new Long(7), null, new Object(), keys,
				     new Character('z'), new THISCLASS<!!>()!>,
				   <!1, 3, 7, 4, 10, 8, 19, 111!>)};
!>)dnl

	for (int i = 0; i < keys.length; ++i) {
	    KEYTYPE key = keys[i];
M?	    VALTYPE val = values[i];

	    check(!vs.containsKey(key), "doesn't contain key " + key + " before adding it");
	    check(vs.size() == i, "reports the right size before adding key " + key);

	    vs.add(key<!!>IFMAP(<!, val!>));
	    check(vs.size() == i + 1, "reports the right size after addition of " + key);
	    check(vs.containsKey(key), "contains key " + key + " after adding it");
M?	    check(vs.getValue(key) == val, "key " + key + " has the right value after adding");
	}

	for (int i = 0; i < keys.length; ++i) {
	    KEYTYPE key = keys[i];
	    check(vs.containsKey(key), "contains once added key " + key);
M?	    check(vs.getValue(key) == values[i], "key " + key + " still has the right value after adding");
	}

	THISCLASS vs2 = new THISCLASS<!!>();
	for (Enumeration e = vs.enumerate(); e.hasMoreElements(); ) {
	    Entry en = (Entry)e.nextElement();
	    vs2.add(en.key<!!>IFMAP(<!, en.value!>));
	}

	check (vs.equals(vs2) && vs2.equals(vs), "sets are equal 1");
	check (vs.hashCode() == vs2.hashCode(), "hashes match 1");

	THISCLASS vs3 = new THISCLASS<!!>();
	THISCLASS vs4 = new THISCLASS<!!>();
	THISCLASS vs5 = new THISCLASS<!!>();
	for (int i = keys.length - 1; i >= 0; --i)
	    vs3.add(keys[i]IFMAP(<!, values[i]!>));

	check(vs.equals(vs3) && vs3.equals(vs), "sets are equal 2");
	check(vs.hashCode() == vs3.hashCode(), "hashes match 2");
	check(vs4.equals(vs5) && vs5.equals(vs4), "sets are equal 3");
	check(vs4.hashCode() == vs5.hashCode(), "hashes match 3");
	check(!vs3.equals(vs5) && !vs5.equals(vs3), "sets not equal 3");
	// This test is dubious, but there should be no collisions on
	// sets built in such an obvious way.
	check(vs3.hashCode() != vs5.hashCode(), "hashes don't match 3");
	check(vs.containsAll(vs4), "non-empty set contains empty set");
	check(vs4.containsAll(vs5), "empty set contains other empty set");
	check(vs.containsAll(vs) && vs.containsAll(vs3), "a set contains the same set");

	for (int i = 0; i < keys.length; ++i)
	    if ((i % 2) == 0)
		vs4.add(keys[i]IFMAP(<!, values[i]!>));
	check(vs.containsAll(vs4), "a set contains it's own \"odd\" subset");
	THISCLASS vs6 = new THISCLASS<!!>(vs4);

	vs5.addAll(vs4);
	check(vs5.equals(vs4), "sets are the same after addAll");
	check(vs5.hashCode() == vs4.hashCode(), "hashes are the same after addAll");

	vs5.addAll(vs);
	check(vs5.equals(vs), "sets are the same after addAll 2");
	check(vs5.hashCode() == vs.hashCode(), "hashes are the same after addAll 2");

	vs5.retainAll(vs4);
	check(vs5.equals(vs4), "sets are the same after retainAll");
	check(vs5.equals(vs4), "sets are the same after retainAll");

	for (int i = 0; i < keys.length; ++i) {
	    int s = vs4.size();
	    boolean should = (i % 2) == 0;
	    boolean was = vs4.remove(keys[i]);
	    check(should == was, "<element should be in the set> matches <element is in the set>");
	    check(!should || vs4.size() == s - 1, "the size changed after removal of element that should be in the set");
	    check(!vs4.containsKey(keys[i]), "the element disappeared");
	}
	check(vs4.equals(new THISCLASS<!!>()), "set is empty");

	vs5.removeAll(vs5);
	check(vs5.size() == 0, "the set is empty after self-subtraction");
	vs5.addAll(vs6);
	vs5.removeAll(vs6);
	check(vs5.size() == 0, "the set is empty after subtraction of the same set");

	vs5.addAll(vs6);
	check(THISCLASS.differenceOf(vs5, vs6).size() == 0, "result of differenceOf between two same sets is empty set");
	check(THISCLASS.differenceOf(vs5, vs5).size() == 0, "result of differenceOf between the set and itself");
	check(THISCLASS.differenceOf(vs5, new THISCLASS<!!>()).equals(vs5), "differenceOf set and empty set is original set");

	check(!vs3.containsAny(new THISCLASS<!!>()), "set doesn't contain any key from the empty set");
	check(!(new THISCLASS<!!>()).containsAny(vs3), "empty set doesn't contain any keys");
	check(vs3.containsAny(vs3), "the set contains some keys from itself");
	check(vs3.containsAny(new THISCLASS<!!>(vs3)), "the set contains some keys from the copy of itself");
	check(vs.containsAny(vs6), "the set contains some keys from subset of itself");
	check(vs6.containsAny(vs), "set contains some keys from superset of itself");

	for (int i = 0; i < keys.length; ++i) {
	    THISCLASS tmp = new THISCLASS<!!>();
	    KEYTYPE key = keys[i];
	    tmp.add(key<!!>IFMAP(<!, values[i]!>));
	    check(vs.containsAny(tmp), "set <containsAny> from the set that is one element subset of that set");
	    check(tmp.containsAny(vs), "one element subset of set should contain any from that set");

	    THISCLASS ds = THISCLASS.differenceOf(vs5, tmp);
	    if (vs5.containsKey(key))
		check(ds.size() == vs5.size() - 1, "differenceOf set is smaller by one");
	    else
		check(ds.size() == vs5.size(), "size of differenceOf set didn't change");
	    check(!ds.containsKey(key), "differenceOf set doesn't contain ruled-out key");
	}

	if (failures == 0)
	    System.out.println("All " + totalTests + " tests passed");
	else {
	    System.out.println(totalTests + " tests total");
	    System.out.println(failures + " failed");
	    throw new RuntimeException("Failures!");
	}
    }
!>)dnl
IFNBASIC(<!
    public static void main(String[] vals) {
	System.out.println("(no tests available)");
    }
!>)dnl
}
