filestore-gem
=============

FileStore ruby gem is a tiny little lib for organising a file storage used by some
application.

TODOS
=====

- DOCUMENTATION
- Possibility to rollback actions
- Add test cases

USAGE
=====

Example:

MultiTenantFileStore.instance.set_root_path "<some_path>"
MultiTenantStore.instance.logger = StdoutLogger

o1 = ObserverClass.new
o1.logger = StdoutLogger

MultiTenantFileStore.instance.register o1

tenant = MultiTenantFileStore.instance.create_tenant_store
MultiTenantFileStore.instance.add_to_tenant tenant, "<some_file>", { :original_file => "<some_file>" }