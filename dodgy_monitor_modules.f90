module dodgy_monitor_modules
!
! Module with routines to be called by the program that we are monitoring.
! A monitoring process is spawned and waits until it hears back. If We failed to
! get back in time it assumes that something has gone wrong and will issue an
! abort.

! In this version child_comm is not available outside.

use mpi
implicit none
private
public dodgy_init, dodgy_end, dodgy_seg_start, dodgy_seg_finish

integer :: child_comm

contains

subroutine dodgy_init
integer:: ierr
call mpi_comm_spawn('dodgy_monitor',mpi_argv_null,1,mpi_info_null,0,mpi_comm_self,child_comm,mpi_errcodes_ignore,ierr)

end subroutine dodgy_init

subroutine dodgy_end
integer            :: request, ierr

! Tell the spawned process that there's nothing more to close down and release
! the communicator

call dodgy_seg_start(0)
call mpi_comm_free(child_comm,ierr)

end subroutine dodgy_end

subroutine dodgy_seg_start(secs)
integer,intent(in) :: secs
integer            :: request, ierr

! Need to send to root process of child rather than proc 1 of family
! Blocking send required in this version for some reason.
call mpi_send(secs, 1, mpi_integer, 0, 0, child_comm, ierr)

end subroutine dodgy_seg_start

subroutine dodgy_seg_finish
integer            :: request, ierr

call mpi_ibarrier(child_comm,request,ierr)

end subroutine dodgy_seg_finish

end module dodgy_monitor_modules
