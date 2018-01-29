FROM pypy:2-5.10.0

ADD build.sh /

RUN /build.sh
CMD ["pypy"]
