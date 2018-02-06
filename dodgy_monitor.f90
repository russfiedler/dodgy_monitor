
program dodgy_monitor
!
! A poor man's way of detecting if an MPI program has hung.
!
! Spin wait until we detect that all the parent processes have passed a
! nonblocking barrier.
! If they all finish within a number of seconds nothing happens otherwise
! MPI_ABORT is called.
! 
! 

use mpi

implicit none

integer              :: parent_comm
integer              :: secs


call dodgy_monitor_init

do
   call dodgy_monitor_start_segment(secs)
   if ( secs == 0 ) exit
   call dodgy_monitor_end_segment(secs)
enddo

call dodgy_monitor_end


contains

!!!!!!!!!!!!!!!

   subroutine dodgy_monitor_init
   integer :: ierr
   call mpi_init(ierr)
   call mpi_comm_get_parent(parent_comm, ierr)
   end subroutine dodgy_monitor_init


!!!!!!!!!!!!!!!

   subroutine dodgy_monitor_end
   integer :: ierr
   call mpi_comm_free(parent_comm,ierr)
   call mpi_finalize(ierr)
   end subroutine dodgy_monitor_end


!!!!!!!!!!!!!!!

   subroutine dodgy_monitor_start_segment(secs)

! Get a message from the parent.
! number of seconds to wait
! 0 means no more messages
! get next request number
! This needs to be a blocking receive.

   integer, intent(out) :: secs
   integer :: ierr
   integer :: status(mpi_status_size)
   
   call mpi_recv(secs, 1, MPI_INTEGER, 0, mpi_any_tag, parent_comm,status,ierr)

   end subroutine dodgy_monitor_start_segment

!!!!!!!!!!!!!!!

   subroutine dodgy_monitor_end_segment(max_secs)
! use mpi_ibarrier here. Just need to know everybody has passed their barrier. If so then we proceed.

   integer, intent(in) ::  max_secs

   logical :: flag
   integer :: request, status(mpi_status_size), ierr
   integer :: elapsed_time
   integer :: cnt, cnt1, cnt_rate

   
   call mpi_ibarrier(parent_comm, request,ierr)
   elapsed_time=0
   call system_clock(cnt1,cnt_rate)

! Spin till we get something or abort. I suppose we could sleep.

   do
      call system_clock(cnt)
      elapsed_time=(cnt-cnt1)/real(cnt_rate)
      if(elapsed_time > max_secs) then
         ! It's the end of the world as we know it...
         write(*,*) 'Too long',elapsed_time
         call mpi_abort(parent_comm,1,ierr)
! Not sure if need to abort self. Can't hurt.
         call mpi_abort(mpi_comm_self,1,ierr)
         exit
      endif

! Check if the parent(s) have passed their checkpoints. If so let's go to the
! next one.

      call mpi_test(request,flag,status,ierr)
      if(flag) exit

   enddo

   end subroutine dodgy_monitor_end_segment

end program dodgy_monitor
