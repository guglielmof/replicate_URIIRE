function est = compute_estimations(TAG, sts, s, t, sh, ts, tsh, ssh)

    if strcmp(TAG, 'md2')
        est = sts.coeffs(1)+ ...
            sts.coeffs(strcmp(sts.coeffnames(:), t))+ ...
            sts.coeffs(strcmp(sts.coeffnames(:), s));

    elseif strcmp(TAG, 'md3')
        est = compute_estimations('md2', sts, s, t, sh, ts, tsh, ssh)  ...
                + sts.coeffs(strcmp(sts.coeffnames(:), ts));

    elseif strcmp(TAG, 'md4')
        est = compute_estimations('md3', sts, s, t, sh, ts, tsh, ssh)  ...
                + sts.coeffs(strcmp(sts.coeffnames(:), sh));

    elseif strcmp(TAG, 'md5')
        est = compute_estimations('md4', sts, s, t, sh, ts, tsh, ssh)  ...
               + sts.coeffs(strcmp(sts.coeffnames(:), ssh));

    elseif strcmp(TAG, 'md6')
        est = compute_estimations('md5', sts, s, t, sh, ts, tsh, ssh)  ...
               + sts.coeffs(strcmp(sts.coeffnames(:), tsh));

    end


end
