function cvx_optval = det_root2n( X )
error( nargchk( 1, 1, nargin ) );

% DET_ROOT2N    2n-th root of the determinant of a symmetric matrix.
%     For a square matrix X, DET_ROOT2N(X) returns
%         POW(DET(X),1/(2*size(X,1))
%     if X is symmetric (real) or Hermitian (complex) and positive
%     semidefinite, and -Inf otherwise.
%
%     This function can be used in many convex optimization problems that
%     call for LOG(DET(X)) instead. For example, if the objective function
%     contains nothing but LOG(DET(X)), it can be replaced with
%     DET_ROOT2N(X), and the same optimal point will be produced.
%
%     Disciplined convex programming information:
%         DET_ROOT2N is concave and nonmonotonic; therefore, when used in
%         CVX specifications, its argument must be affine.

if ndims( X ) > 2,
    
    error( 'N-D arrays are not supported.' );
    
elseif diff( size( X ) ) ~= 0,
    
    error( 'Matrix must be square.' );
    
elseif cvx_isconstant( X ),
    
    cvx_optval = det_root2n( cvx_constant( X ) );
    
elseif isreal( X ),

    n = size(X,1);
    cvx_begin
        variable Z(n,n) lower_triangular
        maximize geomean( diag( Z ) )
        subject to
            [ eye(n,n), Z' ; Z, X ] == semidefinite(2*n);
    cvx_end
    
else,
    
    n = size(X,1);
    cvx_begin
        variable Z(n,n) lower_triangular complex
        maximize geomean( real( diag( Z ) ) )
        subject to
            [ eye(n,n), Z' ; Z, X ] == hermitian_semidefinite(2*n);
            imag( diag( Z ) ) == 0;
    cvx_end
    
end
