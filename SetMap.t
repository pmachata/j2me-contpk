// -*-java-*-
changequote(<!,!>)dnl
ifelse(KIND, <!Map!>, <!define(<!IFMAP!>,<!$1!>)!>, <!define(<!IFMAP!>,<!!>)!>)dnl
ifelse(KIND, <!Set!>, <!define(<!IFSET!>,<!$1!>)!>, <!define(<!IFSET!>,<!!>)!>)dnl
define(<!THISCLASS!>, <!KIND<!!>XVARTYPE<!!>IFMAP(<!XVALTYPE!>)!>)dnl
define(<!SETCLASS!>, <!Set<!!>XVARTYPE!>)dnl
import java.util.Enumeration;

public class THISCLASS {

IFMAP(<!dnl
    /** Thrown when variable is added with different value. */
    public class VariableConflictException extends RuntimeException {
	private VariableConflictException(String message) {
	    super(message);
	}
    }

!>)dnl
    // Storage for variables and their values.
    //  * VARIABLES is an array of variable numbers (e.g. [1, 2, 4]
    //    means variables v1, v2 and v4 are in set
    //  * COUNT is the number of variables in set (3 in above case)
    VARTYPE[] variables;
    int count;

IFMAP(<!dnl
    //  * VALUES in an array of values of variables.  Values are given
    //    in the same order as in VARIABLES array.  E.g. [false,
    //    false, true] would suggest v1=false, v2=false and v4=true.
    VALTYPE[] values;

!>)dnl
    //  * INDEX maps variable numbers to their position in VARIABLES
    //    and VALUES.  INDEX[n] contains position of variable n, or -1
    //    if the variable isn't in set.  In the above case it would
    //    look like [-1, 0, 1, -1, 2, -1, -1, ...]
    int[] index;

    private void maybeResize() {
	if (variables == null || count + 1 > variables.length) {
	    int ocapacity = variables == null ? 0 : variables.length;
	    int capacity = variables == null ? 2 : ocapacity * 2;

	    //System.out.println("resize: " + ocapacity + "->" + capacity);
	    VARTYPE[] nvariables = new VARTYPE[capacity];
M?	    VALTYPE[] nvalues = new VALTYPE[capacity];

	    for (int i = 0; i < ocapacity; ++i) {
		nvariables[i] = variables[i];
M?		nvalues[i] = values[i];
	    }
	    variables = nvariables;
M?	    values = nvalues;
	}
    }

    private VARTYPE roundPower2(VARTYPE variable) {
	variable |= variable >> 1;
	variable |= variable >> 2;
	variable |= variable >> 4;
	variable |= variable >> 8;
	variable |= variable >> 16;
	++variable;
	if (variable <= 0)
	    return XVARTYPE.MAX_VALUE;
	return variable;
    }

    private void accomodateVariable(VARTYPE variable) {
	if (index == null || index.length <= variable) {
	    int oicapacity = index == null ? 0 : index.length;
	    int icapacity = roundPower2(variable);
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
	variables = null;
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

	VARTYPE var;
	for (Iterator ve = set1.iterator(); ve.hasMoreElements(); )
	    if (!set2.containsVariable(var = ve.nextElement()))
		ret.addVariable(var<!!>IFMAP(<!, ve.getValue()!>));
	return ret;
    }

IFMAP(<!dnl
    public SETCLASS keys() {
	SETCLASS k = new SETCLASS<!!>();
	for (int i = 0; i < count; ++i)
	    k.addVariable(variables[i]);
	return k;
    }

!>)dnl
    public int size() {
	return count;
    }

    public boolean containsVariable(VARTYPE variable) {
	if (index != null && variable < index.length)
	    return index[variable] != -1;
	else
	    return false;
    }

M?  public VALTYPE getValue(VARTYPE variable) {
M?	return values[index[variable]];
M?  }

    /**
     * This operation can be used as a "push".  The value is added to the end
     * of the internal queue, and the same variable will be answered
     * after the following call to popVariable.  This holds UNLESS any
     * removeVariable call occurs inbetween, and UNLESS variable was
     * present in the set before.
     */
    public void addVariable(VARTYPE variable<!!>IFMAP(<!, VALTYPE value!>))IFMAP(<!
	throws VariableConflictException!>) {

	if (variable < 0)
	    throw new IllegalArgumentException
		("Can't add negative variable to the set.");

	if (!containsVariable(variable)) {
	    accomodateVariable(variable);
	    maybeResize();

	    index[variable] = count;
M?	    values[count] = value;
	    variables[count++] = variable;

	}IFMAP(<! else if (values[index[variable]] != value)
	    throw new VariableConflictException
		("Request to add variable f" + variable
		 + " with value " + value
		 + "; previously assigned was " + values[index[variable]]);!>)
    }

    public boolean removeVariable(VARTYPE variable) {
	if (!containsVariable(variable))
	    return false;

	int idx = index[variable];
	index[variable] = -1;
	count--;
	if (count > 0 && idx != count) {
	    // move last element to freed index
	    index[variables[count]] = idx;
	    variables[idx] = variables[count];
M?	    values[idx] = values[count];
	}
	return true;
    }

    public VARTYPE popVariable() {
	VARTYPE var = variables[count - 1];
	removeVariable(var);
	return var;
    }

    public class Iterator {
	int i = 0;
	private Iterator() {}

    	public boolean hasMoreElements() {
	    return i < count;
	}
	public VARTYPE nextElement() {
	    return variables[i++];
	}
	public void remove() {
	    removeVariable(variables[i - 1]);
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
	public final VARTYPE variable;
M?	public final VALTYPE value;
	private Entry(VARTYPE var<!!>IFMAP(<!, VALTYPE val!>)) {
	    variable = var;
M?	    value = val;
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
		return new Entry(THISCLASS.this.variables[o]IFMAP(<!,
				 THISCLASS.this.values[o]!>));
	    }
	};
    }

    public boolean containsAll(SETCLASS other) {
	// I can't contain all of the set that is larger than me.
	if (other.count > count)
	    return false;

	for (int i = 0; i < other.count; ++i) {
	    VARTYPE var = other.variables[i];
	    if (!containsVariable(var))
		return false;
	}

	return true;
    }

    public boolean containsAny(SETCLASS other) {
	for (int i = 0; i < other.count; ++i) {
	    VARTYPE var = other.variables[i];
	    if (containsVariable(var))
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
    public void addAll(THISCLASS other)IFMAP(<! throws VariableConflictException!>) {
	if (this == other)
	    return;
	else
	    for (int i = 0; i < other.count; ++i)
		addVariable(other.variables[i]IFMAP(<!, other.values[i]!>));
    }

    public void removeAll(THISCLASS other) {
	if (this == other)
	    clear();
	else
	    for (int i = 0; i < other.count; ++i)
		removeVariable(other.variables[i]);
    }

    public void retainAll(THISCLASS other) {
	if (this == other)
	    return;
	else
	    for (int i = 0; i < count; ++i) {
		VARTYPE var = variables[i];
		if (!other.containsVariable(var)) {
		    removeVariable(var);
		    --i;
		}
	    }
    }

IFMAP(<!dnl
    private boolean valuesSame(THISCLASS other) {
	for (int i = 0; i < count; ++i) {
	    VARTYPE var = variables[i];
	    if (getValue(var) != other.getValue(var))
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
	    return containsAll(other)
		&& other.containsAll(this)IFMAP(<!
		&& valuesSame(other)!>);
    }

    public String toString() {
	StringBuffer buf = new StringBuffer();
	buf.append('{');
	for (int i = 0; i < count; ++i) {
	    if (i > 0)
		buf.append(", ");
	    buf.append(variables[i])IFMAP(<!.append('=').append(values[i])!>);
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

	VARTYPE[] variables = {2, 4, 50, 8, 9, 10, 15, 20};
IFMAP(<!dnl
	VALTYPE[] values = {ifelse(XVALTYPE, <!Boolean!>,
				   <!true, false, false, false, true, false, true, false!>,
				   XVALTYPE, <!Object!>,
				   <!new Integer(1), "Ahoj", new Long(7), null, new Object(), variables,
				     new Character('z'), new THISCLASS<!!>()!>,
				   <!1, 3, 7, 4, 10, 8, 19, 111!>)};
!>)dnl

	for (int i = 0; i < variables.length; ++i) {
	    VARTYPE var = variables[i];
M?	    VALTYPE val = values[i];

	    check(!vs.containsVariable(var), "doesn't contain variable x" + var + " before adding it");
	    check(vs.size() == i, "reports the right size before adding variable x" + var );

	    vs.addVariable(var<!!>IFMAP(<!, val!>));
	    check(vs.size() == i + 1, "reports the right size after addition of x" + var);
	    check(vs.containsVariable(var), "contains variable x" + var + " after adding it");
M?	    check(vs.getValue(var) == val, "variable x" + var + " has the right value after adding");
	}

	for (int i = 0; i < variables.length; ++i) {
	    VARTYPE var = variables[i];
	    check(vs.containsVariable(var), "contains once added variable x" + var);
M?	    check(vs.getValue(var) == values[i], "variable x" + var + " still has the right value after adding");
	}

	THISCLASS vs2 = new THISCLASS<!!>();
	for (Enumeration e = vs.enumerate(); e.hasMoreElements(); ) {
	    Entry en = (Entry)e.nextElement();
	    vs2.addVariable(en.variable<!!>IFMAP(<!, en.value!>));
	}

	check (vs.equals(vs2) && vs2.equals(vs), "sets are equal 1");

	THISCLASS vs3 = new THISCLASS<!!>();
	THISCLASS vs4 = new THISCLASS<!!>();
	THISCLASS vs5 = new THISCLASS<!!>();
	for (int i = variables.length - 1; i >= 0; --i)
	    vs3.addVariable(variables[i]IFMAP(<!, values[i]!>));

	check(vs.equals(vs3) && vs3.equals(vs), "sets are equal 2");
	check(vs4.equals(vs5) && vs5.equals(vs4), "sets not equal 3");
	check(vs.containsAll(vs4), "non-empty set contains empty set");
	check(vs4.containsAll(vs5), "empty set contains other empty set");
	check(vs.containsAll(vs) && vs.containsAll(vs3), "a set contains the same set");

	for (int i = 0; i < variables.length; ++i)
	    if ((i % 2) == 0)
		vs4.addVariable(variables[i]IFMAP(<!, values[i]!>));
	check(vs.containsAll(vs4), "a set contains it's own \"odd\" subset");
	THISCLASS vs6 = new THISCLASS<!!>(vs4);

	vs5.addAll(vs4);
	check(vs5.equals(vs4), "sets are the same after addAll");

	vs5.addAll(vs);
	check(vs5.equals(vs), "sets are the same after addAll 2");

	vs5.retainAll(vs4);
	check(vs5.equals(vs4), "sets are the same after retainAll");

	for (int i = 0; i < variables.length; ++i) {
	    int s = vs4.size();
	    boolean should = (i % 2) == 0;
	    boolean was = vs4.removeVariable(variables[i]);
	    check(should == was, "<element should be in the set> matches <element is in the set>");
	    check(!should || vs4.size() == s - 1, "the size changed after removal of element that should be in the set");
	    check(!vs4.containsVariable(variables[i]), "the element disappeared");
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

	check(!vs3.containsAny(new THISCLASS<!!>()), "set doesn't contain any variable from the empty set");
	check(!(new THISCLASS<!!>()).containsAny(vs3), "empty set doesn't contain any variables");
	check(vs3.containsAny(vs3), "the set contains some variables from itself");
	check(vs3.containsAny(new THISCLASS<!!>(vs3)), "the set contains some variables from the copy of itself");
	check(vs.containsAny(vs6), "the set contains some variables from subset of itself");
	check(vs6.containsAny(vs), "set contains some variables from superset of itself");

	for (int i = 0; i < variables.length; ++i) {
	    THISCLASS tmp = new THISCLASS<!!>();
	    VARTYPE var = variables[i];
	    tmp.addVariable(var<!!>IFMAP(<!, values[i]!>));
	    check(vs.containsAny(tmp), "set <containsAny> from the set that is one element subset of that set");
	    check(tmp.containsAny(vs), "one element subset of set should contain any from that set");

	    THISCLASS ds = THISCLASS.differenceOf(vs5, tmp);
	    if (vs5.containsVariable(var))
		check(ds.size() == vs5.size() - 1, "differenceOf set is smaller by one");
	    else
		check(ds.size() == vs5.size(), "size of differenceOf set didn't change");
	    check(!ds.containsVariable(var), "differenceOf set doesn't contain ruled-out variable");
	}

	if (failures == 0)
	    System.out.println("All " + totalTests + " tests passed");
	else {
	    System.out.println(totalTests + " tests total");
	    System.out.println(failures + " failed");
	    throw new RuntimeException("Failures!");
	}
    }
}
