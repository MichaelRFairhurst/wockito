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

### Generate mock classes

*If you're using the wake project seed, these commands are run for you when you import the right classes*

To generate a mock class, its stubber, and its verifier, run the command

	node wockito-generator -d $TABLE_DIRECTORY -o some/path/to/output/file.wk some/path/to/src/wake/class.wk

To generate your mock provider, run the command

	node wockito-generator -p -d $TABLE_DIRECTORY -o some/path/to/output/file.wk FirstProvidedClass SecondProvidedClass ThirdProvidedClass

And then you can import the classes (you must import them all) like this:

	import PrinterMock;
	import PrinterVerifier;
	import PrinterStubber;
	import MockProvider;

As I said before, wake-project-seed includes a makefile that will see those imports and automatically generate & compile their sources for you.

### Fetch a mock from the provider

   var PrinterMock <- mocks;

Each mock you fetch will be unique.

### Set a return value from a mock

    mocks.when(MapMock).get("Key").thenReturn(value);

You can also set multiple values to return in a row.

    mocks.when(MapMock).get("Key")
		.thenReturn(valueOne)
		.thenReturn(valueTwo);

Eventually I will add matchers to arguments, but not yet.

### Stub a provision value from a mock

	(When{File} <- FilePathMock).thenReturn(mockFile);
	(When{User}:LoggedIn <- AppMock).thenReturn(mockUser);

### Verify mock interactions

Currently, verifying a method with no arguments was called doesn't work! Sorry!

    mocks.verify(MapMock).put("key", value);
    mocks.verify(0)Times(MapMock).put("key", value);
    mocks.verify(2)Times(MapMock).put("key", value);
    mocks.verifyAtLeast(2)Times(MapMock).put("key", value);
    mocks.verifyAtMost(2)Times(MapMock).put("key", value);

### Verify provisions (not sure why you would do this)

* not implemented yet *

    Verify{File} <- mocks.verify(FilePathMock);
    Verify{File} <- mocks.verify(0)Times(FilePathMock);
    Verify{File} <- mocks.verify(2)Times(FilePathMock);
    Verify{File} <- mocks.verifyAtLeast(2)Times(FilePathMock);
    Verify{File} <- mocks.verifyAtMost(2)Times(FilePathMock);

### Verify in order

* not implemented yet *

	var InOrder <- mocks;
	InOrder.add(File).add(FilePath);

	InOrder.verify(FilePath).delete();
	InOrder.verify(FilePath).open();
	InOrder.verify(File).write("hello");
	InOrder.verify(File).close();

### Spies

Spies aren't made just yet!
