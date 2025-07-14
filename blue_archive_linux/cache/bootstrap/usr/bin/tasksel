#!/usr/bin/perl
# Debian task selector, mark II.
# Copyright 2004-2011 by Joey Hess <joeyh@debian.org>.
# Licensed under the GPL, version 2 or higher.
use 5.014;
use Locale::gettext;
use Getopt::Long;
use warnings;
use strict;
textdomain('tasksel');

my $debconf_helper="/usr/lib/tasksel/tasksel-debconf";
my $testdir="/usr/lib/tasksel/tests";
my $packagesdir="/usr/lib/tasksel/packages";
my $descdir="/usr/share/tasksel/descs";
my $localdescdir="/usr/local/share/tasksel/descs";
my $statusfile="/var/lib/dpkg/status";
my $infodir="/usr/lib/tasksel/info";

# This boolean indicates whether we are in dry-run (no-do) mode.  More
# specifically, it disables the actual running of commands by the
# &run() function.
my $testmode=0;

my $taskpackageprefix="task-";

sub warning {
	print STDERR "tasksel: @_\n";
}

sub error {
	print STDERR "tasksel: @_\n";
	exit 1;
}

# my $statuscode = &run("ls", "-l", "/tmp");
# => 0
# Run a shell command except in test mode, and returns its exit code.
# Prints the command in test mode. Parameters should be pre-split for
# system.
sub run {
	if ($testmode) {
		print join(" ", @_)."\n";
		return 0;
	}
	else {
		return system(@_) >> 8;
	}
}

# my @paths = &list_task_descs();
# => ("/path/to/debian-tasks.desc", "/some/other/taskfile.desc")
# Get the list of desc files.
sub list_task_descs {
	# Setting DEBIAN_TASKS_ONLY is a way for the Debian installer
	# to tell tasksel to only use the Debian tasks (from
	# tasksel-data).
	if ($ENV{DEBIAN_TASKS_ONLY}) {
		return glob("$descdir/debian-tasks.desc");
	}
	else {
		return glob("$descdir/*.desc"), glob("$localdescdir/*.desc");
	}
}

# &read_task_desc("/path/to/taskfile.desc");
# => (
#      {
#        task => "gnome-desktop",
#        parent => "desktop",
#        relevance => 1,
#        key => [task-gnome-desktop"],
#        section => "user",
#        test-default-desktop => "3 gnome",
#        sortkey => 1desktop-01
#      },
#      ...
#    )
# Returns a list of hashes; hash values are arrays for multi-line fields.
sub read_task_desc {
	my $desc=shift;

        # %tasks maps the name of each task (the Task: field) to its
        # %%data information (that maps each key to value(s), see the
        # %"while" loop below).
	my %tasks;

	open (DESC, "<$desc") || die "Could not open $desc for reading: $!";
	local $/="\n\n";
	while (defined($_ = <DESC>)) {
		# %data will contain the keys/values of the current
		# stanza.
                # 
                # The keys are stored lowercase.
                # 
                # A single-line value is stored as a scalar "line1"; a
                # multi-line value is stored as a ref to array
                # ["line1", "line2"].
                #
                # $data{relevance} is set to 5 if not otherwise
                # specified in the stanza.
		my %data;

		my @lines=split("\n");
		while (@lines) {
			my $line=shift(@lines);
			if ($line=~/^([^ ]+):(?: (.*))?/) {
				my ($key, $value)=($1, $2);
				$key=lc($key);
				if (@lines && $lines[0] =~ /^\s+/) {
					# multi-line field
					my @values;

                                        # Ignore the first line if it is empty.
					if (defined $value && length $value) {
						push @values, $value;
					}

					while (@lines && $lines[0] =~ /^\s+(.*)/) {
						push @values, $1;
						shift @lines;
					}
					$data{$key}=[@values];
				}
				else {
					$data{$key}=$value;
				}
			}
			else {
				warning "$desc: in stanza $.: warning: parse error, ignoring line: $line";
			}
		}
		$data{relevance}=5 unless exists $data{relevance};
		if (exists $data{task}) {
			$tasks{$data{task}} = \%data;
		}
	}
	close DESC;

	my @ret;
        # In this loop, we simultaneously:
        # 
        # - enrich the %data structures of all tasks with a
        #   ->{sortkey} field
        #
        # - and collect them into @ret.
	foreach my $task (keys %tasks) {
		my $t=$tasks{$task};
		if (exists $t->{parent} && exists $tasks{$t->{parent}}) {
                        # This task has a "Parent:" task.  For example:
                        #
                        #   Task: sometask
                        #   Relevance: 3
                        #   Parent: parenttask
                        #
                        #   Task: parenttask
                        #   Relevance: 6
                        #
                        # In this case, we set the sortkey to "6parenttask-03".
                        #
                        # XXX TODO: support correct sorting when
                        # Relevance is 10 or more (e.g. package
                        # education-tasks).
			$t->{sortkey}=$tasks{$t->{parent}}->{relevance}.$t->{parent}."-0".$t->{relevance};
		}
		else {
                        # This task has no "Parent:" task.  For example:
                        # 
                        #   Task: sometask
                        #   Relevance: 3
                        #
                        # In this case, we set the sortkey to "3sometask-00".
			$t->{sortkey}=$t->{relevance}.$t->{task}."-00";
		}
		push @ret, $t;
	}
	return @ret;
}

# &all_tasks();
# => (
#      {
#        task => "gnome-desktop",
#        parent => "desktop",
#        relevance => 1,
#        key => [task-gnome-desktop"],
#        section => "user",
#        test-default-desktop => "3 gnome",
#        sortkey => 1desktop-01
#      },
#      ...
#    )
# Loads info for all tasks, and returns a set of task structures.
sub all_tasks {
	my %seen;
        # Filter out duplicates: only the first occurrence of each
        # task name is taken into account.
	grep { $seen{$_->{task}}++; $seen{$_->{task}} < 2 }
	map { read_task_desc($_) } list_task_descs();
}


# my %apt_available = %_info_avail()
# => (
#   "debian-policy" => { priority => "optional", section => "doc" },
#   ...
# )
# 
# Call "apt-cache dumpavail" and collect the output information about
# package name, priority and section.
sub _info_avail {
	my %ret = ();
	# Might be better to use the perl apt bindings, but they are not
	# currently in base.
	open (AVAIL, "apt-cache dumpavail|");
	local $_;
	my ($package, $section, $priority);
	while (<AVAIL>) {
		chomp;
		if (not $_) {
                        # End of stanza
			if (defined $package && defined $priority && defined $section) {
				$ret{$package} = {
				       	"priority" => $priority,
					"section" => $section,
				};
			}
		}
		elsif (/^Package: (.*)/) {
			$package = $1;
		}
		elsif (/^Priority: (.*)/) {
			$priority = $1;
		}
		elsif (/^Section: (.*)/) {
			$section = $1;
		}
	}
	close AVAIL;
	return %ret;
}

# my @installed = &list_installed();
# => ("emacs", "vim", ...)
# Returns a list of all installed packages.
# This is not memoised and will run dpkg-query at each invocation.
# See &package_installed() for memoisation.
sub list_installed {
	my @list;
	open (LIST, q{LANG=C dpkg-query -W -f='${Package} ${Status}\n' |});
	while (<LIST>) {
                # Each line looks like this:
                # "adduser install ok installed"
		if (/^([^ ]+) .* installed$/m) {
			push @list, $1;
		}
	}
	close LIST;
	return @list;
}

my %_info_avail_cache;

# my $apt_available = &info_avail();
# => {
#   "debian-policy" => { priority => "optional", section => "doc" },
#   ...
# }
# Returns a hash of all available packages.  Memoised.
sub info_avail {
	my $package = shift;
	if (!%_info_avail_cache) {
		%_info_avail_cache = _info_avail();
	}
	return \%_info_avail_cache;
}

# if (&package_avail("debian-policy")) { ... }
# Given a package name, checks to see if it's installed or available.
# Memoised.
sub package_avail {
	my $package = shift;
	return info_avail()->{$package} || package_installed($package);
}

# Memoisation for &package_installed().
my %installed_pkgs;

# if (&package_installed("debian-policy")) { ... }
# Given a package name, checks to see if it's installed.  Memoised.
sub package_installed {
	my $package=shift;
	
	if (! %installed_pkgs) {
		foreach my $pkg (list_installed()) {
			$installed_pkgs{$pkg} = 1;
		}
	}

	return $installed_pkgs{$package};
}

# if (&task_avail($task)) { ... }
# Given a task hash, checks that all of its key packages are installed or available.
# Returns true if all key packages are installed or available.
# Returns false if any of the key packages is not.
sub task_avail {
	local $_;
	my $task=shift;
	if (! ref $task->{key}) {
		return 1;
	}
	else {
		foreach my $pkg (@{$task->{key}}) {
			if (! package_avail($pkg)) {
				return 0;
			}
		}
		return 1;
	}
}

# if (&task_installed($task)) { ... }
# Given a task hash, checks to see if it is already installed.
# All of its key packages must be installed.  Other packages are not checked.
sub task_installed {
	local $_;
	my $task=shift;
	if (! ref $task->{key}) {
		return 0; # can't tell with no key packages
	}
	else {
		foreach my $pkg (@{$task->{key}}) {
			if (! package_installed($pkg)) {
				return 0;
			}
		}
		return 1;
	}
}

# my @packages = &task_packages($task);
# Given a task hash, returns a list of all available packages in the task.
# 
# It is the list of "Key:" packages, plus the packages indicated
# through the "Packages:" field.
sub task_packages {
	my $task=shift;
	
        # The %list hashtable is used as a set: only its keys matter,
        # the value is irrelevant.
	my %list;

	# "Key:" packages are always included.
	if (ref $task->{key}) {
                # $task->{key} is not a line but a reference (to an
                # array of lines).
		map { $list{$_}=1 } @{$task->{key}};
	}
	
	if (! defined $task->{packages}) {
                # No "Packages:" field.
		# only key
	}
	elsif ($task->{packages} eq 'standard') {
                # Special case of "Packages: standard"
                #
                # The standard packages are the non-library ones in
                # "main" which priority is required, important or
                # standard.
                #
                # We add all standard packages to %list, except the
                # ones that are already installed.
		my %info_avail=%{info_avail()};
		while (my ($package, $info) = each(%info_avail)) {
			my ($priority, $section) = ($info->{priority}, $info->{section});
			if (($priority eq 'required' ||
			     $priority eq 'important' ||
			     $priority eq 'standard') &&
		            # Exclude packages in non-main and library sections
		            $section !~ /^lib|\// &&
			    # Exclude already installed packages
		            !package_installed($package)) {
				$list{$package} = 1;
			}
		}
	}
	else {
		# external method
		my ($method, @params);

                # "Packages:" requests to run a program and use its
                # output as the names of packages.
                #
                # There are basically two forms:
                #
                #   Packages: myprogram
                #
                # Runs /usr/lib/tasksel/packages/myprogram TASKNAME
                #
                #   Packages: myprogram
                #     arg1
                #     arg2...
                #
                # Runs /usr/lib/tasksel/packages/myprogram TASKNAME arg1 arg2...
                #
                # The tasksel package provides the simple "list"
                # program which simply outputs its arguments.
		if (ref $task->{packages}) {
			@params=@{$task->{packages}};
			$method=shift @params;
		}
		else {
			$method=$task->{packages};
		}
		
		map { $list{$_}=1 }
			grep { package_avail($_) }
			split(' ', `$packagesdir/$method $task->{task} @params`);
	}

	return keys %list;
}

# &task_test($task, $new_install, $display_by_default, $install_by_default);
# Given a task hash, runs any test program specified in its data, and sets
# the _display and _install fields to 1 or 0 depending on its result.
#
# If _display is true, _install means the default proposal shown to
# the user, who can modify it.  If _display is false, _install says
# what to do, without asking the user.
sub task_test {
	my $task=shift;
	my $new_install=shift;
	$task->{_display} = shift; # default
	$task->{_install} = shift; # default
	$ENV{NEW_INSTALL}=$new_install if defined $new_install;
        # Each task may define one or more tests in the form:
        #
        #   Test-PROGRAM: ARGUMENTS...
        #
        # Each of the programs will be run like this:
        #
        #   /usr/lib/tasksel/tests/PROGRAM TASKNAME ARGUMENTS...
        #
        # If $new_install is true, the NEW_INSTALL environment
        # variable is set for invoking the program.
        #
        # The return code of the invocation then indicates what to set:
        #
        #   0 - don't display, but install it
        #   1 - don't display, don't install
        #   2 - display, mark for installation
        #   3 - display, don't mark for installation
        #   anything else - don't change the values of _display or _install
	foreach my $test (grep /^test-.*/, keys %$task) {
		$test=~s/^test-//;
		if (-x "$testdir/$test") {
			my $ret=system("$testdir/$test", $task->{task}, split " ", $task->{"test-$test"}) >> 8;
			if ($ret == 0) {
				$task->{_display} = 0;
				$task->{_install} = 1;
			}
			elsif ($ret == 1) {
				$task->{_display} = 0;
				$task->{_install} = 0;
			}
			elsif ($ret == 2) {
				$task->{_display} = 1;
				$task->{_install} = 1;
			}
			elsif ($ret == 3) {
				$task->{_display} = 1;
				$task->{_install} = 0;
			}
		}
	}
	
	delete $ENV{NEW_INSTALL};
	return $task;
}

# &hide_enhancing_tasks($task);
# 
# Hides a task and marks it not to be installed if it enhances other
# tasks.
#
# Returns $task.
sub hide_enhancing_tasks {
	my $task=shift;
	if (exists $task->{enhances} && length $task->{enhances}) {
		$task->{_display} = 0;
		$task->{_install} = 0;
	}
	return $task;
}

# &getdescriptions(@tasks);
# 
# Looks up the descriptions of a set of tasks, returning a new list
# with the ->{shortdesc} fields filled in.
#
# Ideally, the .desc file would indicate a description of each task,
# which would be retrieved quickly.  For missing Description fields,
# we fetch the data with "apt-cache show task-TASKNAME...", which
# takes longer.
#
# @tasks: list of references, each referencing a task data structure.
# 
# Each data structured is enriched with a ->{shortdesc} field,
# containing the localized short description.
#
# Returns @tasks.
sub getdescriptions {
	my @tasks=@_;

	# If the task has a description field in the task desc file,
	# just use it, looking up a translation in gettext.
	@tasks = map {
		if (defined $_->{description}) {
			$_->{shortdesc}=dgettext("debian-tasks", $_->{description}->[0]);
		}
		$_;
	} @tasks;

	# Otherwise, a more expensive apt-cache query is done,
	# to use the descriptions of task packages.
	my @todo = grep { ! defined $_->{shortdesc} } @tasks;
	if (@todo) {
		open(APT_CACHE, "apt-cache show ".join(" ", map { $taskpackageprefix.$_->{task} } @todo)." |") || die "apt-cache show: $!";
		local $/="\n\n";
		while (defined($_ = <APT_CACHE>)) {
			my ($name)=/^Package: $taskpackageprefix(.*)$/m;
			my ($description)=/^Description-(?:[a-z][a-z](?:_[A-Z][A-Z])?): (.*)$/m;
			($description)=/^Description: (.*)$/m
				unless defined $description;
			if (defined $name && defined $description) {
				@tasks = map {
					if ($_->{task} eq $name) {
						$_->{shortdesc}=$description;
					}
					$_;
				} @tasks;
			}
		}
		close APT_CACHE;
	}

	return @tasks;
}

# &task_to_debconf(@tasks);
# => "task1, task2, task3"
# Converts a list of tasks into a debconf list of the task short
# descriptions.
sub task_to_debconf {
	join ", ", map { format_description_for_debconf($_) } getdescriptions(@_);
}

# my $debconf_string = &format_description_for_debconf($task);
# => "... GNOME"
# Build a string for making a debconf menu item.
# If the task has a parent task, "... " is prepended.
sub format_description_for_debconf {
	my $task=shift;
	my $d=$task->{shortdesc};
	$d=~s/,/\\,/g;
	$d="... ".$d if exists $task->{parent};
	return $d;
}

# my $debconf_string = &task_to_debconf_C(@tasks);
# => "gnome-desktop, kde-desktop"
# Converts a list of tasks into a debconf list of the task names.
sub task_to_debconf_C {
	join ", ", map { $_->{task} } @_;
}

# my @my_tasks = &list_to_tasks("task1, task2, task3", @tasks);
# => ($task1, $task2, $task3)
# Given a first parameter that is a string listing task names, and then a
# list of task hashes, returns a list of hashes for all the tasks
# in the list.
sub list_to_tasks {
	my $list=shift;
	my %lookup = map { $_->{task} => $_ } @_;
	return grep { defined } map { $lookup{$_} } split /[, ]+/, $list;
}

# my @sorted_tasks = &order_for_display(@tasks);
# Orders a list of tasks for display.
# The tasks are ordered according to the ->{sortkey}.
sub order_for_display {
	sort {
		$a->{sortkey} cmp $b->{sortkey}
		              || 0 ||
	        $a->{task} cmp $b->{task}
	} @_;
}

# &name_to_task($taskname, &all_tasks());
# &name_to_task("gnome-desktop", &all_tasks());
# => {
#      task => "gnome-desktop",
#      parent => "desktop",
#      relevance => 1,
#      key => [task-gnome-desktop"],
#      section => "user",
#      test-default-desktop => "3 gnome",
#      sortkey => 1desktop-01
#    }
# Given a set of tasks and a name, returns the one with that name.
sub name_to_task {
	my $name=shift;
	return (grep { $_->{task} eq $name } @_)[0];
}

# &task_script($task, "preinst") or die;
# Run the task's (pre|post)(inst|rm) script, if there is any.
# Such scripts are located under /usr/lib/tasksel/info/.
sub task_script {
	my $task=shift;
	my $script=shift;

	my $path="$infodir/$task.$script";
	if (-e $path && -x _) {
		my $ret=run($path);
		if ($ret != 0) {
			warning("$path exited with nonzero code $ret");
			return 0;
		}
	}
	return 1;
}

# &usage;
# Print the usage.
sub usage {
        print STDERR gettext(q{tasksel [OPTIONS...] [COMMAND...]
 Commands:
  install TASK...       install tasks
  remove TASK...        uninstall tasks
  --task-packages=TASK  list packages installed by TASK; can be repeated
  --task-desc=TASK      print the description of a task
  --list-tasks          list tasks that would be displayed and exit
 Options:
  -t, --test            dry-run: don't really change anything
      --new-install     automatically install some tasks
  --debconf-apt-progress="ARGUMENTS..."
                        provide additional arguments to debconf-apt-progress(1)
});
}

# Process command line options and return them in a hash.
sub getopts {
	my %ret;
	Getopt::Long::Configure ("bundling");
	if (! GetOptions(\%ret, "test|t", "new-install", "list-tasks",
		   "task-packages=s@", "task-desc=s",
		   "debconf-apt-progress=s")) {
		usage();
		exit(1);
	}
	# Special case apt-like syntax.
	if (@ARGV) {
		my $cmd = shift @ARGV;
		if ($cmd eq "install") {
			$ret{cmd_install} = \@ARGV;
		}
		elsif ($cmd eq "remove") {
			$ret{cmd_remove} = \@ARGV;
		}
		else {
			usage();
			exit 1;
		}
	}
	$testmode=1 if $ret{test}; # set global
	return %ret;
}

# &interactive($options, @tasks);
# Ask the user and mark tasks to install or remove accordingly.
# The tasks are enriched with ->{_install} or ->{_remove} set to true accordingly.
sub interactive {
	my $options = shift;
	my @tasks = @_;

	if (! $options->{"new-install"}) {
		# Don't install hidden tasks if this is not a new install.
		map { $_->{_install} = 0 } grep { $_->{_display} == 0 } @tasks;
	}

	my @list = order_for_display(grep { $_->{_display} == 1 } @tasks);
	if (@list) {
		if (! $options->{"new-install"}) {
			# Find tasks that are already installed.
			map { $_->{_installed} = task_installed($_) } @list;
			# Don't install new tasks unless manually selected.
			map { $_->{_install} = 0 } @list;
		}
		else {
			# Assume that no tasks are installed, to ensure
			# that complete tasks get installed on new
			# installs.
			map { $_->{_installed} = 0 } @list;
		}
		my $question="tasksel/tasks";
		if ($options->{"new-install"}) {
			$question="tasksel/first";
		}
		my @default = grep { $_->{_display} == 1 && ($_->{_install} == 1 || $_->{_installed} == 1) } @tasks;
		my $tmpfile=`mktemp`;
		chomp $tmpfile;
		my $ret=system($debconf_helper, $tmpfile,
			task_to_debconf_C(@list),
			task_to_debconf(@list),
			task_to_debconf_C(@default),
			$question) >> 8;
		if ($ret == 30) {
			exit 10; # back up
		}
		elsif ($ret != 0) {
			error "debconf failed to run";
		}
		open(IN, "<$tmpfile");
		$ret=<IN>;
		if (! defined $ret) {
			die "tasksel canceled\n";
		}
		chomp $ret;
		close IN;
		unlink $tmpfile;
		
		# Set _install flags based on user selection.
		map { $_->{_install} = 0 } @list;
		foreach my $task (list_to_tasks($ret, @tasks)) {
			if (! $task->{_installed}) {
				$task->{_install} = 1;
			}
			$task->{_selected} = 1;
		}
		foreach my $task (@list) {
			if (! $task->{_selected} && $task->{_installed}) {
				$task->{_remove} = 1;
			}
		}
	}

        # When a $task Enhances: a @group_of_tasks, it means that
        # $task can only be installed if @group_of_tasks are also
        # installed; and if @group_of_tasks is installed, it is an
        # incentive to also install $task.
        #
        # For example, consider this task:
        # 
        #   Task: amharic-desktop
        #   Enhances: desktop, amharic
        #
        # The task amharic-desktop installs packages that make
        # particular sense if the user wants both a desktop and the
        # amharic language environment.  Conversely, if
        # amharic-desktop is selected (e.g. by preseeding), then it
        # automatically also selects tasks "desktop" and "amharic".

	# If an enhancing task is already marked for
	# install, probably by preseeding, mark the tasks
	# it enhances for install.
	foreach my $task (grep { $_->{_install} && exists $_->{enhances} &&
	                         length $_->{enhances} } @tasks) {
		map { $_->{_install}=1 } list_to_tasks($task->{enhances}, @tasks);
	}

	# Select enhancing tasks for install.
	# XXX FIXME ugly hack -- loop until enhances settle to handle
	# chained enhances. This is ugly and could loop forever if
	# there's a cycle.
	my $enhances_needswork=1;

        # %tested is the memoization of the below calls to
        # %&task_test().
	my %tested;

        # Loop as long as there is work to do.
	while ($enhances_needswork) {
		$enhances_needswork=0;

                # Loop over all unselected tasks that enhance one or
                # more things.
		foreach my $task (grep { ! $_->{_install} && exists $_->{enhances} &&
		                         length $_->{enhances} } @tasks) {
                        # TODO: the computation of %tasknames could be
                        # done once and for all outside of this nested
                        # loop, saving some redundant work.
			my %tasknames = map { $_->{task} => $_ } @tasks;

                        # @deps is the list of tasks enhanced by $task.
                        # 
                        # Basically, if all the deps are installed,
                        # and tests say that $task can be installed,
                        # then mark it to install.  Otherwise, don't
                        # install it.
			my @deps=map { $tasknames{$_} } split ", ", $task->{enhances};

			if (grep { ! defined $_ } @deps) {
				# task enhances an unavailable or
				# uninstallable task
				next;
			}

			if (@deps) {
                                # FIXME: isn't $orig_state always
                                # false, given that the "for" loop
                                # above keeps only $tasks that do
                                # not have $_->{_install}?
				my $orig_state=$task->{_install};

				# Mark enhancing tasks for install if their
				# dependencies are met and their test fields
				# mark them for install.
				if (! exists $tested{$task->{task}}) {
					$ENV{TESTING_ENHANCER}=1;
					task_test($task, $options->{"new-install"}, 0, 1);
					delete $ENV{TESTING_ENHANCER};
					$tested{$task->{task}}=$task->{_install};
				}
				else {
					$task->{_install}=$tested{$task->{task}};
				}

				foreach my $dep (@deps) {
					if (! $dep->{_install}) {
						$task->{_install} = 0;
					}
				}

				if ($task->{_install} != $orig_state) {
					# We have made progress:
					# continue another round.
                                        $enhances_needswork=1;
				}
			}
		}
	}

}

sub main {
	my %options=getopts();
	my @tasks_remove;
	my @tasks_install;

	# Options that output stuff and don't need a full processed list of
	# tasks.
	if (exists $options{"task-packages"}) {
		my @tasks=all_tasks();
		foreach my $taskname (@{$options{"task-packages"}}) {
			my $task=name_to_task($taskname, @tasks);
			if ($task) {
				print "$_\n" foreach task_packages($task);
			}
		}
		exit(0);
	}
	elsif ($options{"task-desc"}) {
		my $task=name_to_task($options{"task-desc"}, all_tasks());
		if ($task) {
                        # The Description looks like this:
                        #
                        #   Description: one-line short description
                        #     Longer description,
                        #     possibly spanning
                        #     multiple lines.
                        #
                        # $extdesc will contain the long description,
                        # reformatted to one line.
			my $extdesc=join(" ", @{$task->{description}}[1..$#{$task->{description}}]);
			print dgettext("debian-tasks", $extdesc)."\n";
			exit(0);
		}
		else {
			fprintf STDERR ("Task %s has no description\n", $options{"task-desc"});
			exit(1);
		}
	}

	# This is relatively expensive, get the full list of available tasks and
	# mark them.
	my @tasks=map { hide_enhancing_tasks($_) } map { task_test($_, $options{"new-install"}, 1, 0) }
	          grep { task_avail($_) } all_tasks();
	
	if ($options{"list-tasks"}) {
		map { $_->{_installed} = task_installed($_) } @tasks;
		@tasks=getdescriptions(@tasks);
                # TODO: use printf() instead of print for correct column alignment
		print "".($_->{_installed} ? "i" : "u")." ".$_->{task}."\t".$_->{shortdesc}."\n"
			foreach order_for_display(grep { $_->{_display} } @tasks);
		exit(0);
	}
	
	if ($options{cmd_install}) {
		@tasks_install = map { name_to_task($_, @tasks) } @{$options{cmd_install}};
	}
	elsif ($options{cmd_remove}) {
		@tasks_remove = map { name_to_task($_, @tasks) } @{$options{cmd_remove}};
	}
	else {
		interactive(\%options, @tasks);

		# Add tasks to install
		@tasks_install = grep { $_->{_install} } @tasks;
		# Add tasks to remove
		@tasks_remove = grep { $_->{_remove} } @tasks;
	}

	my @cmd;
	if (-x "/usr/bin/debconf-apt-progress") {
		@cmd = "debconf-apt-progress";
		push @cmd, split(' ', $options{'debconf-apt-progress'})
			if exists $options{'debconf-apt-progress'};
		push @cmd, "--";
	}
	push @cmd, qw{apt-get -q -y -o APT::Install-Recommends=true -o APT::Get::AutomaticRemove=true -o Acquire::Retries=3 install};

	# And finally, act on selected tasks.
	if (@tasks_install || @tasks_remove) {
		foreach my $task (@tasks_remove) {
			push @cmd, map { "$_-" } task_packages($task);
			task_script($task->{task}, "prerm");
		}
		foreach my $task (@tasks_install) {
			push @cmd, task_packages($task);
			task_script($task->{task}, "preinst");
		}
		my $ret=run(@cmd);
		if ($ret != 0) {
			error gettext("apt-get failed")." ($ret)";
		}
		foreach my $task (@tasks_remove) {
			task_script($task->{task}, "postrm");
		}
		foreach my $task (@tasks_install) {
			task_script($task->{task}, "postinst");
		}
	}
}

main();
