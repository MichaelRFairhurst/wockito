Wockito
==========

Standard mocking framework for Wake


Based heavily on Mockito, except where missing features from wake/new features in wake make it difficult to do so.

### Compile a MockProvider for your project

First compile all of your classes. Then run the mock compiler.

    ./wake-mock-compiler

If you are using wake-seed, the makefile does this in the proper order for you.

You will then get source files for a bunch of mocks that have the capability of being your classes in the gen/ directory. You will also get a MockProvider class.

### Include MockProvider in a test

In your test case, it should look like this:

    import Asserts;
    import MockProvider;

    every TestWithMocks is:

        needs mocks MockProvider;

        ~[ test something ]~(Asserts) {
            mocks.use(Asserts);
		}

For each test you must use(Asserts), until the day we have exceptions. Otherwise your failed assertions get squished!

### Fetch a mock from the provider

   var Printer <- mocks;

Each mock you fetch will be unique.

### Set a return value from a mock

    mocks.when(Map).get("Key").thenReturn(value);

You can also set multiple values to return in a row.

    mocks.when(Map).get("Key")
		.thenReturn(valueOne)
		.thenReturn(valueTwo);

Eventually I will add matchers to arguments, but not yet.

### Stub a provision value from a mock

	(Stub{File} <- mocks.when(FilePath)).thenReturn(mockFile);
	(Stub{User}:LoggedIn <- mocks.when(App)).thenReturn(mockUser);

### Verify mock interactions

    mocks.verify(Map).put("key", value);
    mocks.verify(0)Times(Map).put("key", value);
    mocks.verify(2)Times(Map).put("key", value);
    mocks.verifyAtLeast(2)Times(Map).put("key", value);
    mocks.verifyAtMost(2)Times(Map).put("key", value);

### Verify provisions (not sure why you would do this)

    Verify{File} <- mocks.verify(FilePath);
    Verify{File} <- mocks.verify(0)Times(FilePath);
    Verify{File} <- mocks.verify(2)Times(FilePath);
    Verify{File} <- mocks.verifyAtLeast(2)Times(FilePath);
    Verify{File} <- mocks.verifyAtMost(2)Times(FilePath);

### Verify in order

	var InOrder <- mocks;
	InOrder.add(File).add(FilePath);

	InOrder.verify(FilePath).delete();
	InOrder.verify(FilePath).open();
	InOrder.verify(File).write("hello");
	InOrder.verify(File).close();

### Spies

Spies aren't made just yet!
