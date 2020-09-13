#!/usr/bin/env python3
import apt

cache = apt.Cache()

for name in cache.keys():
    if name.startswith('task-') and name.endswith('-desktop'):
        pkg = cache.get(name).versions[0]
        deps = sum([[dep] if hasattr(dep, 'name') else dep for dep in pkg.recommends], [])
        fdeps = [dep for dep in deps if dep.name.startswith('fonts-')]
        if fdeps:
            print("Recommends: %s\nWhy: %s\n" % (', '.join(dep.name for dep in fdeps), name))
