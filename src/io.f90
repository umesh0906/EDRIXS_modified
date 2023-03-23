!!>>> read control parameters
subroutine config()
    use m_constants, only: mystd, mytmp
    use m_control
    use mpi

    implicit none

    logical :: exists
    integer :: ierror 

    namelist /control/ ed_solver, num_val_orbs, num_core_orbs, neval, nvector, &
                       idump, num_gs, maxiter, linsys_max, min_ndim, ncv, &
                       eigval_tol, linsys_tol, nkryl, omega_in, gamma_in

    ! default values
    ed_solver = 1
    num_val_orbs = 2
    num_core_orbs = 2
    neval = 1
    nvector = 1
    idump = .false.
    num_gs = 1
    maxiter = 500
    linsys_max = 500
    min_ndim = 1000
    ncv = neval + 2
    eigval_tol = 1E-8
    linsys_tol = 1E-8
    nkryl = 500
    omega_in = 0.0
    gamma_in = 0.1

    exists = .false.
    inquire(file = 'config.in', exist = exists)
    if ( .not. exists ) then
        write(mystd, "(100a)") " fedrixs >>> ERROR: config.in doesn't exist"
        STOP
    endif

    if (origin_myid == master) then
        open(mytmp, file='config.in')            
        read(mytmp, NML=control) 
        close(mytmp)
    endif

    call MPI_BCAST(ed_solver,       1, MPI_INTEGER, master, origin_comm, ierror)
    call MPI_BCAST(num_val_orbs,    1, MPI_INTEGER, master, origin_comm, ierror)
    call MPI_BCAST(num_core_orbs,   1, MPI_INTEGER, master, origin_comm, ierror)
    call MPI_BCAST(neval,           1, MPI_INTEGER, master, origin_comm, ierror)
    call MPI_BCAST(nvector,         1, MPI_INTEGER, master, origin_comm, ierror)
    call MPI_BCAST(num_gs,          1, MPI_INTEGER, master, origin_comm, ierror)
    call MPI_BCAST(maxiter,         1, MPI_INTEGER, master, origin_comm, ierror)
    call MPI_BCAST(min_ndim,        1, MPI_INTEGER, master, origin_comm, ierror)
    call MPI_BCAST(ncv,             1, MPI_INTEGER, master, origin_comm, ierror)
    call MPI_BCAST(nkryl,           1, MPI_INTEGER, master, origin_comm, ierror)
    call MPI_BCAST(linsys_max,      1, MPI_INTEGER, master, origin_comm, ierror)
    call MPI_BCAST(idump,           1, MPI_LOGICAL, master, origin_comm, ierror)
    call MPI_BCAST(eigval_tol,      1, MPI_DOUBLE_PRECISION, master, origin_comm, ierror)
    call MPI_BCAST(linsys_tol,      1, MPI_DOUBLE_PRECISION, master, origin_comm, ierror)
    call MPI_BCAST(omega_in,        1, MPI_DOUBLE_PRECISION, master, origin_comm, ierror)
    call MPI_BCAST(gamma_in,        1, MPI_DOUBLE_PRECISION, master, origin_comm, ierror)

    call MPI_BARRIER(origin_comm, ierror)

    return
end subroutine config

!!>>> read hopping terms for initial configuration
subroutine read_hopping_i()
    use m_constants, only: dp, mystd, mytmp
    use m_control,   only: myid, master, new_comm, nhopp_i
    use m_global,    only: hopping_i, alloc_hopping_i
    use mpi

    implicit none

    logical :: exists
    integer :: i, j
    integer :: num
    integer :: ierror
    real(dp) :: rdum1, rdum2

    exists = .false.
    inquire(file = "hopping_i.in", exist=exists)
    if ( .not. exists ) then
        write(mystd, "(100a)") " fedrixs >>> ERROR: hopping_i.in doesn't exist"
        STOP
    endif

    if (myid == master) then
        open(mytmp, file="hopping_i.in")
        read(mytmp, *) nhopp_i
        call alloc_hopping_i()
        do num=1,nhopp_i
            read(mytmp, *) i, j, rdum1, rdum2
            hopping_i(num)%ind1 = i 
            hopping_i(num)%ind2 = j 
            hopping_i(num)%val  = dcmplx(rdum1, rdum2)
        enddo
        close(mytmp)
    endif 

    call MPI_BCAST(nhopp_i,  1, MPI_INTEGER,  master, new_comm, ierror)
    if (myid /= master) then
        call alloc_hopping_i()
    endif
    call MPI_BARRIER(new_comm, ierror)
    do i=1,nhopp_i
        call MPI_BCAST(hopping_i(i)%ind1, 1, MPI_INTEGER,        master, new_comm, ierror)
        call MPI_BCAST(hopping_i(i)%ind2, 1, MPI_INTEGER,        master, new_comm, ierror)
        call MPI_BCAST(hopping_i(i)%val,  1, MPI_DOUBLE_COMPLEX, master, new_comm, ierror)
    enddo
    call MPI_BARRIER(new_comm, ierror)

    return
end subroutine read_hopping_i

!!>>> read Coulomb interaction terms for initial configuration
subroutine read_coulomb_i()
    use m_constants, only: dp, mystd, mytmp
    use m_control,   only: myid, master, new_comm, ncoul_i
    use m_global,    only: coulomb_i, alloc_coulomb_i
    use mpi

    implicit none

    logical :: exists
    integer :: i, j, k, l
    integer :: num
    integer :: ierror
    real(dp) :: rdum1, rdum2

    exists = .false.
    inquire(file = "coulomb_i.in", exist=exists)
    if ( .not. exists ) then
        write(mystd, "(100a)") " fedrixs >>> ERROR: coulomb_i.in doesn't exist"
        STOP
    endif

    if (myid == master) then
        open(mytmp, file="coulomb_i.in")
        read(mytmp, *) ncoul_i 
        call alloc_coulomb_i()
        do num=1,ncoul_i
            read(mytmp, *) i, j, k, l, rdum1, rdum2
            coulomb_i(num)%ind1 = i
            coulomb_i(num)%ind2 = j
            coulomb_i(num)%ind3 = k
            coulomb_i(num)%ind4 = l
            coulomb_i(num)%val  = dcmplx(rdum1, rdum2)
        enddo
        close(mytmp)
    endif 

    call MPI_BCAST(ncoul_i, 1, MPI_INTEGER, master, new_comm, ierror)
    if (myid /= master) then
        call alloc_coulomb_i()
    endif
    call MPI_BARRIER(new_comm, ierror)
    do i=1,ncoul_i
        call MPI_BCAST(coulomb_i(i)%ind1, 1, MPI_INTEGER,        master, new_comm, ierror)
        call MPI_BCAST(coulomb_i(i)%ind2, 1, MPI_INTEGER,        master, new_comm, ierror)
        call MPI_BCAST(coulomb_i(i)%ind3, 1, MPI_INTEGER,        master, new_comm, ierror)
        call MPI_BCAST(coulomb_i(i)%ind4, 1, MPI_INTEGER,        master, new_comm, ierror)
        call MPI_BCAST(coulomb_i(i)%val,  1, MPI_DOUBLE_COMPLEX, master, new_comm, ierror)
    enddo
    call MPI_BARRIER(new_comm, ierror)

    return
end subroutine read_coulomb_i

!!>>> read fock basis for initial configuration
subroutine read_fock_i()
    use m_constants, only: mystd, mytmp
    use m_control,   only: ndim_i
    use m_global,    only: fock_i, alloc_fock_i

    implicit none

    logical :: exists
    integer :: num

    inquire(file = "fock_i.in", exist=exists)
    if (exists .eqv. .true.) then
        open(mytmp, file="fock_i.in")
        read(mytmp, *) ndim_i
        call alloc_fock_i()
        do num=1,ndim_i
            read(mytmp, *) fock_i(num)
        enddo
        close(mytmp)
    else
        write(mystd, "(100a)") "fock_i.in doesn't exist"
        STOP
    endif

    return
end subroutine read_fock_i

!!>>> read hopping terms for intermediate configuration
subroutine read_hopping_n()
    use m_constants, only: dp, mystd, mytmp
    use m_control,   only: myid, master, new_comm, nhopp_n
    use m_global,    only: hopping_n, alloc_hopping_n
    use mpi

    implicit none

    ! local variables
    logical :: exists
    integer :: i, j
    integer :: num
    integer :: ierror
    real(dp) :: rdum1, rdum2

    exists = .false.
    inquire(file = "hopping_n.in", exist=exists)
    if ( .not. exists ) then
        write(mystd, "(100a)") " fedrixs >>> ERROR: hopping_n.in doesn't exist"
        STOP
    endif

    if (myid == master) then
        open(mytmp, file="hopping_n.in")
        read(mytmp, *) nhopp_n
        call alloc_hopping_n()
        do num=1,nhopp_n
            read(mytmp, *) i, j, rdum1, rdum2
            hopping_n(num)%ind1 = i 
            hopping_n(num)%ind2 = j 
            hopping_n(num)%val  = dcmplx(rdum1, rdum2)
        enddo
        close(mytmp)
    endif 

    call MPI_BCAST(nhopp_n, 1, MPI_INTEGER, master, new_comm, ierror)
    if (myid /= master) then
        call alloc_hopping_n()
    endif
    call MPI_BARRIER(new_comm, ierror)
    do i=1,nhopp_n
        call MPI_BCAST(hopping_n(i)%ind1, 1, MPI_INTEGER,        master, new_comm, ierror)
        call MPI_BCAST(hopping_n(i)%ind2, 1, MPI_INTEGER,        master, new_comm, ierror)
        call MPI_BCAST(hopping_n(i)%val,  1, MPI_DOUBLE_COMPLEX, master, new_comm, ierror)
    enddo
    call MPI_BARRIER(new_comm, ierror)

    return
end subroutine read_hopping_n

!!>>> read Coulomb interaction terms for intermediate configuration
subroutine read_coulomb_n()
    use m_constants, only: dp, mystd, mytmp
    use m_control,   only: myid, master, new_comm, ncoul_n
    use m_global,    only: coulomb_n, alloc_coulomb_n
    use mpi

    implicit none

    logical :: exists
    integer :: i, j, k, l
    integer :: num
    integer :: ierror
    real(dp) :: rdum1, rdum2

    exists = .false.
    inquire(file = "coulomb_n.in", exist=exists)
    if ( .not. exists ) then
        write(mystd, "(100a)") " fedrixs >>> ERROR: coulomb_n.in doesn't exist"
        STOP
    endif

    if (myid == master) then
        open(mytmp, file="coulomb_n.in")
        read(mytmp, *) ncoul_n
        call alloc_coulomb_n()
        do num=1,ncoul_n
            read(mytmp, *) i, j, k, l, rdum1, rdum2
            coulomb_n(num)%ind1 = i
            coulomb_n(num)%ind2 = j
            coulomb_n(num)%ind3 = k
            coulomb_n(num)%ind4 = l
            coulomb_n(num)%val  = dcmplx(rdum1, rdum2)
        enddo
        close(mytmp)
    endif 

    call MPI_BCAST(ncoul_n, 1, MPI_INTEGER, master, new_comm, ierror)
    if (myid /= master) then
        call alloc_coulomb_n()
    endif
    call MPI_BARRIER(new_comm, ierror)
    do i=1,ncoul_n
        call MPI_BCAST(coulomb_n(i)%ind1, 1, MPI_INTEGER,        master, new_comm, ierror)
        call MPI_BCAST(coulomb_n(i)%ind2, 1, MPI_INTEGER,        master, new_comm, ierror)
        call MPI_BCAST(coulomb_n(i)%ind3, 1, MPI_INTEGER,        master, new_comm, ierror)
        call MPI_BCAST(coulomb_n(i)%ind4, 1, MPI_INTEGER,        master, new_comm, ierror)
        call MPI_BCAST(coulomb_n(i)%val,  1, MPI_DOUBLE_COMPLEX, master, new_comm, ierror)
    enddo
    call MPI_BARRIER(new_comm, ierror)

    return
end subroutine read_coulomb_n

!! read fock basis for intermediate states
!! without including the degree of freedom of core orbitals
subroutine read_fock_n()
    use m_constants, only: mystd, mytmp
    use m_control,   only: ndim_n_nocore
    use m_global,    only: fock_n, alloc_fock_n

    implicit none

    logical :: exists
    integer :: num

    inquire(file = "fock_n.in", exist=exists)
    if (exists .eqv. .true.) then
        open(mytmp, file="fock_n.in")
        read(mytmp, *) ndim_n_nocore
        call alloc_fock_n()
        do num=1,ndim_n_nocore
            read(mytmp, *) fock_n(num)
        enddo
        close(mytmp)
    else
        write(mystd, "(100a)") " fedrixs >>> ERROR: fock_n.in doesn't exist"
        STOP
    endif

    return
end subroutine read_fock_n

!! read fock basis for final configuration
subroutine read_fock_f()
    use m_constants, only: mystd, mytmp
    use m_control,   only: ndim_f
    use m_global,    only: fock_f, alloc_fock_f

    implicit none

    logical :: exists
    integer :: num

    inquire(file = "fock_f.in", exist=exists)
    if (exists .eqv. .true.) then
        open(mytmp, file="fock_f.in")
        read(mytmp, *) ndim_f
        call alloc_fock_f()
        do num=1,ndim_f
            read(mytmp, *) fock_f(num)
        enddo
        close(mytmp)
    else
        write(mystd, "(100a)") " fedrixs >>> ERROR: fock_f.in doesn't exist"
        STOP
    endif

    return
end subroutine read_fock_f

!! read transition operators for XAS 
subroutine read_transop_xas()
    use m_constants, only: dp, mystd, mytmp
    use m_control,   only: myid, master, new_comm, ntran_xas
    use m_global,    only: transop_xas, alloc_transop_xas
    use mpi

    implicit none

    logical :: exists
    integer :: i, j
    integer :: num
    integer :: ierror
    real(dp) :: rdum1, rdum2

    exists = .false.
    inquire(file = "transop_xas.in", exist=exists)
    if ( .not. exists ) then
        write(mystd, "(100a)") " fedrixs >>> ERROR: transop_xas.in doesn't exist"
        STOP
    endif

    if (myid == master) then
        open(mytmp, file="transop_xas.in")
        read(mytmp, *) ntran_xas
        call alloc_transop_xas()
        do num=1,ntran_xas
            read(mytmp, *) i, j, rdum1, rdum2
            transop_xas(num)%ind1 = i 
            transop_xas(num)%ind2 = j 
            transop_xas(num)%val  = dcmplx(rdum1, rdum2)
        enddo
        close(mytmp)
    endif 

    call MPI_BCAST(ntran_xas, 1, MPI_INTEGER, master, new_comm, ierror)
    if (myid /= master) then
        call alloc_transop_xas()
    endif
    call MPI_BARRIER(new_comm, ierror)
    do i=1,ntran_xas
        call MPI_BCAST(transop_xas(i)%ind1, 1, MPI_INTEGER,        master, new_comm, ierror)
        call MPI_BCAST(transop_xas(i)%ind2, 1, MPI_INTEGER,        master, new_comm, ierror)
        call MPI_BCAST(transop_xas(i)%val,  1, MPI_DOUBLE_COMPLEX, master, new_comm, ierror)
    enddo
    call MPI_BARRIER(new_comm, ierror)

    return
end subroutine read_transop_xas

!! read transition operators for absorption process of RIXS
subroutine read_transop_rixs_i()
    use m_constants, only: dp, mystd, mytmp
    use m_control, only: myid, master, new_comm, ntran_rixs_i
    use m_global, only: transop_rixs_i, alloc_transop_rixs_i
    use mpi

    implicit none

    ! local variables
    logical :: exists
    integer :: i, j
    integer :: num
    integer :: ierror
    real(dp) :: rdum1, rdum2

    exists = .false.
    inquire(file = "transop_rixs_i.in", exist=exists)
    if ( .not. exists ) then
        write(mystd, "(100a)") " fedrixs >>> ERROR: transop_rixs_i.in doesn't exist"
        STOP
    endif

    if (myid == master) then
        open(mytmp, file="transop_rixs_i.in")
        read(mytmp, *) ntran_rixs_i
        call alloc_transop_rixs_i()
        do num=1,ntran_rixs_i
            read(mytmp, *) i, j, rdum1, rdum2
            transop_rixs_i(num)%ind1 = i 
            transop_rixs_i(num)%ind2 = j 
            transop_rixs_i(num)%val  = dcmplx(rdum1, rdum2)
        enddo
        close(mytmp)
    endif 

    call MPI_BCAST(ntran_rixs_i, 1, MPI_INTEGER, master, new_comm, ierror)
    if (myid /= master) then
        call alloc_transop_rixs_i()
    endif
    call MPI_BARRIER(new_comm, ierror)
    do i=1,ntran_rixs_i
        call MPI_BCAST(transop_rixs_i(i)%ind1, 1, MPI_INTEGER,        master, new_comm, ierror)
        call MPI_BCAST(transop_rixs_i(i)%ind2, 1, MPI_INTEGER,        master, new_comm, ierror)
        call MPI_BCAST(transop_rixs_i(i)%val,  1, MPI_DOUBLE_COMPLEX, master, new_comm, ierror)
    enddo
    call MPI_BARRIER(new_comm, ierror)

    return
end subroutine read_transop_rixs_i

!! read transition operators for emission process of RIXS
subroutine read_transop_rixs_f()
    use m_constants, only: dp, mystd, mytmp
    use m_control,   only: myid, master, new_comm, ntran_rixs_f
    use m_global,    only: transop_rixs_f, alloc_transop_rixs_f
    use mpi

    implicit none

    logical :: exists
    integer :: i, j
    integer :: num
    integer :: ierror
    real(dp) :: rdum1, rdum2

    exists = .false.
    inquire(file = "transop_rixs_f.in", exist=exists)
    if ( .not. exists ) then
        write(mystd, "(100a)") " fedrixs >>> ERROR: transop_rixs_f.in doesn't exist"
        STOP
    endif

    if (myid == master) then
        open(mytmp, file="transop_rixs_f.in")
        read(mytmp, *) ntran_rixs_f
        call alloc_transop_rixs_f()
        do num=1,ntran_rixs_f
            read(mytmp, *) i, j, rdum1, rdum2
            transop_rixs_f(num)%ind1 = i 
            transop_rixs_f(num)%ind2 = j 
            transop_rixs_f(num)%val  = dcmplx(rdum1, rdum2)
        enddo
        close(mytmp)
    endif 

    call MPI_BCAST(ntran_rixs_f, 1, MPI_INTEGER, master, new_comm, ierror)
    if (myid /= master) then
        call alloc_transop_rixs_f()
    endif
    call MPI_BARRIER(new_comm, ierror)
    do i=1,ntran_rixs_f
        call MPI_BCAST(transop_rixs_f(i)%ind1, 1, MPI_INTEGER,        master, new_comm, ierror)
        call MPI_BCAST(transop_rixs_f(i)%ind2, 1, MPI_INTEGER,        master, new_comm, ierror)
        call MPI_BCAST(transop_rixs_f(i)%val,  1, MPI_DOUBLE_COMPLEX, master, new_comm, ierror)
    enddo
    call MPI_BARRIER(new_comm, ierror)

    return
end subroutine read_transop_rixs_f

!! write poles 
subroutine write_krylov(fname, neff, alpha, beta, norm, e_gs)
    use m_constants, only: dp, mytmp
    use m_control,   only: myid, master

    implicit none

    character(*), intent(in) :: fname
    integer, intent(in) :: neff
    real(dp), intent(in) :: alpha(neff)
    real(dp), intent(in) :: beta(neff)
    real(dp), intent(in) :: norm
    real(dp), intent(in) :: e_gs

    integer :: i

    if (myid==master) then
        open(mytmp, file=fname)
        write(mytmp, "(a20, i10)")    "#number_of_poles:   ",  neff
        write(mytmp, "(a20, f20.10)") "#enegry:            ",  e_gs
        write(mytmp, "(a20, f20.10)") "#normalization:     ",  norm
        do i=1,neff
            write(mytmp, "(i5, 2f20.10)") i, alpha(i), beta(i)
        enddo
        close(mytmp)
    endif
    
end subroutine write_krylov

!! write eigenvectors
subroutine write_eigvecs(fname, nloc, eigvec, eigval)
    use m_constants, only: dp, mytmp

    implicit none

    character(*), intent(in) :: fname
    integer,      intent(in) :: nloc
    complex(dp),  intent(in) :: eigvec(nloc)
    real(dp),     intent(in) :: eigval

    open(mytmp, file=fname, form="unformatted")
    write(mytmp) eigval
    write(mytmp) eigvec
    close(mytmp)
 
    return
end subroutine write_eigvecs

!! read eigenvectors
subroutine read_eigvecs(fname, nloc, eigvec, eigval)
    use m_constants, only: dp, mytmp
    use m_control, only: myid

    implicit none

    character(*), intent(in) :: fname
    integer,      intent(in) :: nloc
    complex(dp),  intent(out) :: eigvec(nloc)
    real(dp),     intent(out) :: eigval

    integer :: file_id

    file_id = mytmp + myid + 1

    open(file_id, file=fname, form="unformatted")
    read(file_id) eigval
    read(file_id) eigvec 
    close(file_id)

    return
end subroutine read_eigvecs

!! write eigenvalues
subroutine write_lowest_eigvals(n, eigval)
    use m_constants, only: dp, mytmp
    use m_control, only: myid, master

    implicit none

    integer, intent(in) :: n
    real(dp), intent(in) :: eigval(n)

    integer :: i

    if (myid==master) then
        open(mytmp, file="eigvals.dat")
        do i=1,n
            write(mytmp, "(i5, f20.10)") i, eigval(i)
        enddo 
        close(mytmp)
    endif

    return
end subroutine write_lowest_eigvals

!! write density matrix
subroutine write_denmat(n, num_orbs, denmat)
    use m_constants, only: dp, mytmp
    use m_control, only: myid, master

    implicit none

    integer, intent(in) :: n
    integer, intent(in) :: num_orbs
    complex(dp), intent(in) :: denmat(num_orbs, num_orbs, n)

    integer :: i,j,k

    if (myid==master) then
        open(mytmp, file="denmat.dat")
        do i=1,n
            do j=1,num_orbs
                do k=1,num_orbs
                    write(mytmp, "(3i5, 2f20.10)") i, j, k, real(denmat(j, k,i)), aimag(denmat(j,k,i))
                enddo
            enddo
        enddo 
        close(mytmp)
    endif

    return
end subroutine write_denmat

!! write opavg
subroutine write_opavg(n, eval, opavg)
    use m_constants, only: dp, mytmp
    use m_control, only: myid, master

    implicit none

    integer, intent(in) :: n
    real(dp), intent(in) :: eval(n)
    complex(dp), intent(in) :: opavg(n)

    integer :: i

    if (myid==master) then
        open(mytmp, file="opavg.dat")
        do i=1,n
            write(mytmp, "(1i5, 4f20.10)") i, eval(i), real(opavg(i)), aimag(opavg(i))
        enddo 
        close(mytmp)
    endif

    return
end subroutine write_opavg


